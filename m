From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Fri, 3 Feb 2017 15:28:01 -0700
Message-ID: <34456681-46d1-0761-3b61-4e308f363126@cumulusnetworks.com>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
 <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com>
 <5894F19A.60305@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33757 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdBCW2D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:28:03 -0500
Received: by mail-pg0-f47.google.com with SMTP id 204so9987940pge.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 14:28:03 -0800 (PST)
In-Reply-To: <5894F19A.60305@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/17 2:09 PM, Daniel Borkmann wrote:
> On 02/03/2017 09:38 PM, David Ahern wrote:
>> Similar to classic bpf, support saving original ebpf instructions
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Not convinced that this is in the right direction, this not only *significantly*
> increases mem footprint for each and every program, but also when you dump this,
> then map references from relocs inside the insns are meaningless (f.e. what about
> prog arrays used in tail calls?), so things like criu also won't be able to use
> this kind of interface for dump and restore. If it's just for debugging, then
> why not extend the existing tracing infrastructure around bpf that was started
> with intention to gain more visibility.


Yes, saving the original bpf increases the memory footprint. If you noticed, a kmemdup is used for the exact instruction size (no page round up). Right now programs are limited to a single page, so worst case  is an extra page per program. I am open to other suggestions. For example, bpf_prog is rounded up to a page which means there could be room at the end of the page for the original instructions. This is definitely true for the ip vrf programs which will be < 32 instructions even with the namespace checking and the conversions done kernel side.

Tracepoints will not solve the problem for me for a number of reasons. Tracepoints have to be hit to return data, and there is no way the tracepoint can return relevant information for me to verify that the correct filter was downloaded. I want the original code. I want to audit what was installed. In my case there could be N VRFs, and I want 'ip vrf' or ifupdown2 or any other command to be able to verify that each cgroup has the correct program, and to verify that the default VRF does *not* have a program installed.

Generically, the bpf code might contain relative data but that's for the user or decoder program to deal with. Surely there is no harm in returning the original, downloaded bpf code to a properly privileged process. If I am debugging some weird network behavior, I want to be able to determine what bpf code is running where and to see what it is doing to whatever degree possible. Saving the original code is the first part of this.

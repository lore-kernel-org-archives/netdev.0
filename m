From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Query] Delayed vxlan socket creation?
Date: Wed, 14 Dec 2016 09:24:08 -0800
Message-ID: <CAM_iQpXujwj_GcN5KOT4vMbPj-H+B+=MdPjpRWZZrc+piooBYg@mail.gmail.com>
References: <5A90DA2E42F8AE43BC4A093BF06788481A9457F1@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mrjana@gmail.com" <mrjana@gmail.com>
To: "Du, Fan" <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33418 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933641AbcLNRYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 12:24:38 -0500
Received: by mail-it0-f67.google.com with SMTP id c20so707010itb.0
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 09:24:29 -0800 (PST)
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF06788481A9457F1@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 11:49 PM, Du, Fan <fan.du@intel.com> wrote:
> Hi
>
> I'm interested to one Docker issue[1] which looks like related to kernel vxlan socket creation
> as described in the thread. From my limited knowledge here, socket creation is synchronous ,
> and after the *socket* syscall, the sock handle will be valid and ready to linkup.

You need to read the code. vxlan tunnel is a UDP tunnel, it needs a kernel
socket (and a port) to setup UDP communication, unlike GRE tunnel etc.


>
> Somehow I'm not sure the detailed scenario here, and which/how possible commit fix?
> Thanks!
>
> Quoted analysis:
> --------------------------------------------------------------------------
> (Found in kernel 3.13)
> The issue happens because in older kernels when a vxlan interface is created,
> the socket creation is queued up in a worker thread which actually creates
> the socket. But this needs to happen before we bring up the link on the vxlan interface.
> If for some chance, the worker thread hasn't completed the creation of the socket
> before we did link up then when we do link up the kernel checks if the socket was
> created and if not it will return ENOTCONN. This was a bug in the kernel which got fixed
> in later kernels. That is why retrying with a timer fixes the issue.


This was introduced by commit 1c51a9159ddefa5119724a4c7da3fd3ef44b68d5
and later fixed by commit 56ef9c909b40483d2c8cb63fcbf83865f162d5ec.

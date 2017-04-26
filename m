From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for returning/setting
 egress port?
Date: Tue, 25 Apr 2017 20:07:34 -0700
Message-ID: <59000EF6.1050204@gmail.com>
References: <20170418215856.5fda7127@redhat.com>
 <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
 <58F7E9F3.5090604@iogearbox.net>
 <20170420025611.GA53935@ast-mbp.thefacebook.com>
 <20170420081051.77a41aa8@redhat.com>
 <20170420171006.GA97067@ast-mbp.thefacebook.com>
 <20170425113453.5c72080f@redhat.com>
 <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34591 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1434697AbdDZDHt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 23:07:49 -0400
In-Reply-To: <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-25 05:26 PM, Alexei Starovoitov wrote:
> On Tue, Apr 25, 2017 at 11:34:53AM +0200, Jesper Dangaard Brouer wrote:
>>> Note the very first bpf patchset years ago contained the port table
>>> abstraction. ovs has concept of vports as well. These two very
>>> different projects needed port table to provide a layer of
>>> indirection between ifindex==netdev and virtual port number.
>>> This is still the case and I'd like to see this port table to be
>>> implemented for both cls_bpf and xdp. In that sense xdp is not
>>> special.
>>
>> Glad to hear you want to see this implemented, I will start coding on
>> this then.  Good point with cls_bpf, I was planning to make this port
>> table strongly connected to XDP, guess I should also think of cls_bpf.
> 
> perfect.
> I think we should try to make all additions to bpf networking world
> to be usable for both tc and xdp, since both are actively used and
> it wouldn't be great to have cool feature for one, but not the other.
> I think port table is an excellent candidate that applies to both.

+1

Jesper, I was working up the code for the redirect piece for ixgbe and
virtio, please use this as a base for your virtual port number table. I'll
push an update onto github tomorrow. I think the table should drop in fairly
nicely.

One piece that isn't clear to me is how do you plan to instantiate and
program this table. Is it a new static bpf map that is created any time we see
the redirect command? I think this would be preferred.

> 
>> I'm not worried about the DROP case, I agree that is fine (as you also
>> say).  The problem is unintentionally sending a packet to a wrong
>> ifindex.  This is clearly an eBPF program error, BUT with XDP this
>> becomes a very hard to debug program error.  With TC-redirect/cls_bpf
>> we can tcpdump the packets, with XDP there is no visibility into this
>> happening (the NSA is going to love this "feature").  Maybe we could add
>> yet-another tracepoint to allow debugging this.  My proposal that we
>> simply remove the possibility for such program errors, by as you say
>> move the validation from run-time into static insertion-time, via a
>> port table.
> 
> I think lack of tcpdump-like debugging in xdp is a separate issue.
> As I was saying in the other thread we have trivial 'xdpdump' kern+user
> app that emits pcap file, but it's too specific to how we use
> tail_calls+prog_array in our xdp setup. I'm working on the program
> chaining that will be generic and allow us transparently add multiple
> xdp or tc progs to the same attachment point and will allow us to
> do 'xdpdump' at any point of this pipeline, so debugging of what
> happened to the packet will be easier and done in the same way
> for both tc and xdp.
> btw in our experience working with both tc and xdp the tc+bpf was
> actually harder to use and more bug prone.
> 

Nice, the tcpdump-like debugging looks interesting.

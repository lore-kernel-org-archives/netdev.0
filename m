From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Sat, 2 Apr 2016 23:11:52 -0700
Message-ID: <20160403061151.GC21980@gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
 <20160402102331.5aa3b3c2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33263 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbcDCGL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 02:11:56 -0400
Received: by mail-pf0-f178.google.com with SMTP id 184so21164498pff.0
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 23:11:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160402102331.5aa3b3c2@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 02, 2016 at 10:23:31AM +0200, Jesper Dangaard Brouer wrote:
[...]
> 
> I think you need to DMA sync RX-page before you can safely access
> packet data in page (on all arch's).
> 
Thanks, I will give that a try in the next spin.
> > +			ethh = (struct ethhdr *)(page_address(frags[0].page) +
> > +						 frags[0].page_offset);
> > +			if (mlx4_call_bpf(prog, ethh, length)) {
> 
> AFAIK length here covers all the frags[n].page, thus potentially
> causing the BPF program to access memory out of bound (crash).
> 
> Having several page fragments is AFAIK an optimization for jumbo-frames
> on PowerPC (which is a bit annoying for you use-case ;-)).
> 
Yeah, this needs some more work. I can think of some options:
1. limit pseudo skb.len to first frag's length only, and signal to
program that the packet is incomplete
2. for nfrags>1 skip bpf processing, but this could be functionally
incorrect for some use cases
3. run the program for each frag
4. reject ndo_bpf_set when frags are possible (large mtu?)

My preference is to go with 1, thoughts?
> 
[...]

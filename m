From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Wed, 13 Jul 2016 07:08:25 -0700
Message-ID: <20160713140535.GA22535@gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
 <063D6719AE5E284EB5DD2968C1650D6D5F4F6ED7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34789 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbcGMOIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 10:08:54 -0400
Received: by mail-pa0-f50.google.com with SMTP id fi15so18213224pac.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 07:08:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4F6ED7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 11:27:23AM +0000, David Laight wrote:
> From: Brenden Blanco
> > Sent: 12 July 2016 08:51
> > Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
> > 
> > In tc/socket bpf programs, helpers linearize skb fragments as needed
> > when the program touches the packet data. However, in the pursuit of
> > speed, XDP programs will not be allowed to use these slower functions,
> > especially if it involves allocating an skb.
> > 
> > Therefore, disallow MTU settings that would produce a multi-fragment
> > packet that XDP programs would fail to access. Future enhancements could
> > be done to increase the allowable MTU.
> 
> Maybe I'm misunderstanding what is going on here...
> But what has the MTU to do with how skb are fragmented?
This is mlx4 specific...depending on the MTU the driver will write data
into 1536, 1536+4096, 1536+4096+4096, etc. fragments.
> 
> If the skb come from a reasonably written USB ethernet interface they could
> easily have arbitrary fragment boundaries (the frames get packed into USB
> buffers).
The XDP program is operating directly on the packet memory, before any
skb has been allocated. The program also expects a continguous memory
region to inspect...it's too expensive to linearize the data like we do
in the tc hook case, that's a feature that costs too much for this type
of low level feature. Therefore, XDP can only be turned on in
combination with a cooperative driver, that's the performance tradeoff
we're imposing here.
> 
> Outbound skb can also have fragments depending on how they are generated.
Sure, but XDP won't run on those. This is an rx-only feature.
> 
> 	David

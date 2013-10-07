From: Matt Wilson <msw@linux.com>
Subject: Re: [PATCH net-next] xen-netback: fix xenvif_count_skb_slots()
Date: Sun, 6 Oct 2013 17:07:41 -0700
Message-ID: <20131007000741.GB5970@u109add4315675089e695.ant.amazon.com>
References: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
 <20131007000652.GA5970@u109add4315675089e695.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Xi Xiong <xixiong@amazon.com>, Matt Wilson <msw@amazon.com>,
	Annie Li <annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Simon Graham <simon.graham@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:44530 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754941Ab3JGAHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 20:07:45 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so6353205pdj.3
        for <netdev@vger.kernel.org>; Sun, 06 Oct 2013 17:07:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131007000652.GA5970@u109add4315675089e695.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 06, 2013 at 05:06:52PM -0700, Matt Wilson wrote:
> On Fri, Oct 04, 2013 at 05:26:23PM +0100, Paul Durrant wrote:
> > Commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c introduced an error into
> > xenvif_count_skb_slots() for skbs with a linear area spanning a page
> > boundary. The alignment of skb->data needs to be taken into account, not
> > just the head length. This patch fixes the issue by dry-running the code
> > from xenvif_gop_skb() (and adjusting the comment above the function to note
> > that).
> > 
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > Cc: Xi Xiong <xixiong@amazon.com>
> > Cc: Matt Wilson <msw@amazon.com>
> > Cc: Annie Li <annie.li@oracle.com>
> > Cc: Wei Liu <wei.liu2@citrix.com>
> > Cc: Ian Campbell <Ian.Campbell@citrix.com>
> 
> Paul, can you reconcile this change with the one made by Simon in cs
> 8f985b4f7a5394c8f8725a5109451a541ddb9eea?

Correction: e26b203ede31fffd52571a5ba607a26c79dc5c0d

> --msw
> 
> > ---
> >  drivers/net/xen-netback/netback.c |   17 +++++++++++++++--
> >  1 file changed, 15 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> > index d0b0feb..6f680f4 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -223,15 +223,28 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
> >  /*
> >   * Figure out how many ring slots we're going to need to send @skb to
> >   * the guest. This function is essentially a dry run of
> > - * xenvif_gop_frag_copy.
> > + * xenvif_gop_skb.
> >   */
> >  unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
> >  {
> > +	unsigned char *data;
> >  	unsigned int count;
> >  	int i, copy_off;
> >  	struct skb_cb_overlay *sco;
> >  
> > -	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
> > +	count = 0;
> > +
> > +	data = skb->data;
> > +	while (data < skb_tail_pointer(skb)) {
> > +		unsigned int offset = offset_in_page(data);
> > +		unsigned int len = PAGE_SIZE - offset;
> > +
> > +		if (data + len > skb_tail_pointer(skb))
> > +			len = skb_tail_pointer(skb) - data;
> > +
> > +		count++;
> > +		data += len;
> > +	}
> >  
> >  	copy_off = skb_headlen(skb) % PAGE_SIZE;
> >  

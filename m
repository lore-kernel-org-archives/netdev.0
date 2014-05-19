From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/13] libertas: make return of 0 explicit
Date: Mon, 19 May 2014 12:25:41 -0500
Message-ID: <1400520341.3819.15.camel@dcbw.local>
References: <1400473875-22228-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1400473875-22228-2-git-send-email-Julia.Lawall@lip6.fr>
	 <5379FCD0.2030506@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	kernel-janitors@vger.kernel.org, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5379FCD0.2030506@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-05-19 at 16:45 +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 19-05-2014 8:31, Julia Lawall wrote:
> 
> > From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> > Delete unnecessary local variable whose value is always 0 and that hides
> > the fact that the result is always 0.
> 
> > A simplified version of the semantic patch that fixes this problem is as
> > follows: (http://coccinelle.lip6.fr/)
> 
> > // <smpl>
> > @r exists@
> > local idexpression ret;
> > expression e;
> > position p;
> > @@
> >
> > -ret = 0;
> > ... when != ret = e
> > return
> > - ret
> > + 0
> >    ;
> > // </smpl>
> 
> > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> > ---
> > Alternatively, was an error code intended in the bad length case, as is
> > done in process_brxed_802_11_packet?
> 
> >   drivers/net/wireless/libertas/rx.c |    7 ++-----
> >   1 file changed, 2 insertions(+), 5 deletions(-)
> 
> > diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
> > index c7366b0..807c5b8 100644
> > --- a/drivers/net/wireless/libertas/rx.c
> > +++ b/drivers/net/wireless/libertas/rx.c
> [...]
> > @@ -154,10 +152,9 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
> >   	else
> >   		netif_rx_ni(skb);
> >
> > -	ret = 0;
> >   done:
> > -	lbs_deb_leave_args(LBS_DEB_RX, "ret %d", ret);
> > -	return ret;
> > +	lbs_deb_leave_args(LBS_DEB_RX, "ret %d", 0);
> 
>     Why not just "ret 0"?

I think instead we want:

diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index c7366b0..e446fed 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -67,30 +67,32 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
 
 	lbs_deb_enter(LBS_DEB_RX);
 
 	BUG_ON(!skb);
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	if (priv->wdev->iftype == NL80211_IFTYPE_MONITOR)
-		return process_rxed_802_11_packet(priv, skb);
+	if (priv->wdev->iftype == NL80211_IFTYPE_MONITOR) {
+		ret = process_rxed_802_11_packet(priv, skb);
+		goto done;
+	}
 
 	p_rx_pd = (struct rxpd *) skb->data;
 	p_rx_pkt = (struct rxpackethdr *) ((u8 *)p_rx_pd +
 		le32_to_cpu(p_rx_pd->pkt_ptr));
 
 	dev = lbs_mesh_set_dev(priv, dev, p_rx_pd);
 
 	lbs_deb_hex(LBS_DEB_RX, "RX Data: Before chop rxpd", skb->data,
 		 min_t(unsigned int, skb->len, 100));
 
 	if (skb->len < (ETH_HLEN + 8 + sizeof(struct rxpd))) {
 		lbs_deb_rx("rx err: frame received with bad length\n");
 		dev->stats.rx_length_errors++;
-		ret = 0;
+		ret = -EINVAL;
 		dev_kfree_skb(skb);
 		goto done;
 	}
 
 	lbs_deb_rx("rx data: skb->len - pkt_ptr = %d-%zd = %zd\n",
 		skb->len, (size_t)le32_to_cpu(p_rx_pd->pkt_ptr),
 		skb->len - (size_t)le32_to_cpu(p_rx_pd->pkt_ptr));

Since that (a) preserves the enter/leave balance when monitor mode is
enabled, and (b) fixes the return code that has been 0 since the driver
was added to the tree in early 2007.  Dave Woodhouse fixed the
process_rxed_802_11_packet() return code for EINVAL case in commit
7bf02c29 from late 2007, and I think the normal codepath should do
EINVAL too.  (though it turns out nothing cares about the return code
anyway, we should still fix it)

Dan

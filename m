From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Fix NULL dereference in rtlwifi driver
Date: Fri, 21 Jan 2011 01:04:21 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101210103240.11854@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101202309030.11854@swampdragon.chaosbits.net> <4D38CB7E.5000304@lwfinger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D38CB7E.5000304@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2011, Larry Finger wrote:

> On 01/20/2011 04:18 PM, Jesper Juhl wrote:
> > In drivers/net/wireless/rtlwifi/pci.c::_rtl_pci_rx_interrupt() we call 
> > dev_alloc_skb(), which may fail and return NULL, but we do not check the 
> > returned value against NULL before dereferencing the returned pointer. 
> > This may lead to a NULL pointer dereference which means we'll crash - not 
> > good.
> > 
> > This patch tries to solve the issue by testing for NULL and bailing out if 
> > we couldn't allocate a skb. However, I don't know this code well, so I'm 
> > not sure that jumping to the 'done' label here is the correct action to 
> > take. Someone more knowledgable about this code than me should definately 
> > review it before it is applied anywhere.
> > While I was in the area I also moved an assignment in 
> > _rtl_pci_init_rx_ring() a bit - if the dev_alloc_skb() call in that 
> > function fails there's no reason to waste clock cycles assigning to the 
> > local variable 'entry', we may as well do that after the NULL check and 
> > potential bail out.
> > 
> > Here's the proposed patch, but please don't take it as much more than a 
> > bug report. If it happens to be correct, then by all means apply it, but 
> > I'm not personally making any guarantees.
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  pci.c |    9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> > 
> >   compile tested only, I don't have the hardware to test for real.
> > 
> > diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
> > index 0fa36aa..5e99f89 100644
> > --- a/drivers/net/wireless/rtlwifi/pci.c
> > +++ b/drivers/net/wireless/rtlwifi/pci.c
> > @@ -619,6 +619,13 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
> >  					struct sk_buff *uskb = NULL;
> >  					u8 *pdata;
> >  					uskb = dev_alloc_skb(skb->len + 128);
> > +					if (!uskb) {
> > +						RT_TRACE(rtlpriv,
> > +							(COMP_INTR | COMP_RECV),
> > +							DBG_DMESG,
> > +							("can't alloc rx skb\n"));
> > +						goto done;
> > +					}
> >  					memcpy(IEEE80211_SKB_RXCB(uskb),
> >  							&rx_status,
> >  							sizeof(rx_status));
> > @@ -1066,9 +1073,9 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw)
> >  			struct sk_buff *skb =
> >  			    dev_alloc_skb(rtlpci->rxbuffersize);
> >  			u32 bufferaddress;
> > -			entry = &rtlpci->rx_ring[rx_queue_idx].desc[i];
> >  			if (!skb)
> >  				return 0;
> > +			entry = &rtlpci->rx_ring[rx_queue_idx].desc[i];
> >  
> >  			/*skb->dev = dev; */
> >  
> 
> This patch looks mostly good to me. The only change I would make is to replace
> "DBG_DMESG" in the RT_TRACE statement with "DBG_EMERG". The standard setting of
> the debug variable does not generate output for DBG_DMESG.
> 
> With that change, ACK and
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> 

Here you go.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 pci.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 0fa36aa..1758d44 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -619,6 +619,13 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 					struct sk_buff *uskb = NULL;
 					u8 *pdata;
 					uskb = dev_alloc_skb(skb->len + 128);
+					if (!uskb) {
+						RT_TRACE(rtlpriv,
+							(COMP_INTR | COMP_RECV),
+							DBG_EMERG,
+							("can't alloc rx skb\n"));
+						goto done;
+					}
 					memcpy(IEEE80211_SKB_RXCB(uskb),
 							&rx_status,
 							sizeof(rx_status));
@@ -641,7 +648,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
 			if (unlikely(!new_skb)) {
 				RT_TRACE(rtlpriv, (COMP_INTR | COMP_RECV),
-					 DBG_DMESG,
+					 DBG_EMERG,
 					 ("can't alloc skb for rx\n"));
 				goto done;
 			}
@@ -1066,9 +1073,9 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw)
 			struct sk_buff *skb =
 			    dev_alloc_skb(rtlpci->rxbuffersize);
 			u32 bufferaddress;
-			entry = &rtlpci->rx_ring[rx_queue_idx].desc[i];
 			if (!skb)
 				return 0;
+			entry = &rtlpci->rx_ring[rx_queue_idx].desc[i];
 
 			/*skb->dev = dev; */
 


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

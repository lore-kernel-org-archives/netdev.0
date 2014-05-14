From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 2/5] 6lowpan: simplify/fix
 payload length calculation
Date: Wed, 14 May 2014 07:27:45 +0200
Message-ID: <20140514052742.GA10566@omega>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1400001846-5349-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1400001846-5349-3-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Phoebe,

sorry I can't test your patches at the moment.

On Tue, May 13, 2014 at 07:24:03PM +0200, Phoebe Buckheister wrote:
> Instead of accounting for all fields of a packet we can think about,
> simply peek the header of a packet we're building and ask ieee802154 how
> many bytes of payload space we have. This also accounts for security
> headers, which were ignored previously.
> 
> Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
> ---
>  net/ieee802154/6lowpan_rtnl.c |   24 ++++++++++++++++--------
>  1 file changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
> index 0f5a69e..3e11b46 100644
> --- a/net/ieee802154/6lowpan_rtnl.c
> +++ b/net/ieee802154/6lowpan_rtnl.c
> @@ -256,6 +256,19 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
>  	return dev_queue_xmit(frag);
>  }
>  
> +static int lowpan_fragment_plen(struct sk_buff *skb, int extra)
> +{
> +	struct ieee802154_hdr hdr;
> +
> +	ieee802154_hdr_peek(skb, &hdr);
> +
> +	/* calc the nearest payload length(divided to 8) for a fragment with
> +	 * a given 802.15.4 hdr and additional lowpan headers which fits into
> +	 * IEEE802154_MTU
> +	 */
> +	return round_down(ieee802154_max_payload(&hdr) - extra, 8);
> +}

Is there a change to use the skb_mac_header_length function here instead
of parsing the mac header? I mean we should already known the mac header
size from the wpan header_create function.

I am not sure when you have the information for the security headers...
maybe we don't have this available at the wpan header_create function.
But when this is true we should reset the skb_mac_header then.
This sounds also bad if the mac header is changed in lowpan device. I
don't know how the security stuff workds right now, sorry.


And maybe we should replace the skb->mac_len in the lowpan_skb_fragmentation
function. :-) This we could put on the todo list. For the global 6LoWPAN
cleanup code patch series.

- Alex


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs

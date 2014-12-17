From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 03/10] ovs: Enable handling of UFO6 packets.
Date: Thu, 18 Dec 2014 00:26:01 +0200
Message-ID: <20141217222601.GA30969@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
	<1418840455-22598-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, stefanha@redhat.com,
	virtualization@lists.linux-foundation.org
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1418840455-22598-4-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 17, 2014 at 01:20:48PM -0500, Vladislav Yasevich wrote:
> Since UFO6 packets can now be identified by SKB_GSO_UDP6, add proper checks
> to handel UFO6 flows.

s/handel/handle/

> Legacy applications may still have UFO6 packets identified by SKB_GSO_UDP,
> so we need to continue to handle them correclty.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  net/openvswitch/datapath.c | 3 ++-
>  net/openvswitch/flow.c     | 2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index f9e556b..b43fc60 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -334,7 +334,8 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
>  		if (err)
>  			break;
>  
> -		if (skb == segs && gso_type & SKB_GSO_UDP) {
> +		if (skb == segs &&
> +		    ((gso_type & SKB_GSO_UDP) || (gso_type & SKB_GSO_UDP6))) {
>  			/* The initial flow key extracted by ovs_flow_extract()
>  			 * in this case is for a first fragment, so we need to
>  			 * properly mark later fragments.
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 2b78789..d03adf4 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -602,7 +602,7 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>  
>  		if (key->ip.frag == OVS_FRAG_TYPE_LATER)
>  			return 0;
> -		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
> +		if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP | SKB_GSO_UDP6))
>  			key->ip.frag = OVS_FRAG_TYPE_FIRST;
>  
>  		/* Transport layer. */
> -- 
> 1.9.3

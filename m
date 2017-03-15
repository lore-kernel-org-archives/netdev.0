From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] bridge: ebtables: fix reception of frames
 DNAT-ed to bridge device
Date: Wed, 15 Mar 2017 11:34:57 +0100
Message-ID: <20170315103457.GA12895@salvia>
References: <20170315031811.22714-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>
To: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170315031811.22714-1-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 15, 2017 at 04:18:11AM +0100, Linus Lüssing wrote:
> When trying to redirect bridged frames to the bridge device itself
> via the ebtables nat-prerouting chain and the dnat target then this
> currently fails:
> 
> The ethernet destination of the frame is dnat'ed to the MAC address of
> the bridge itself just fine and the correctly altered frame can even
> be captured via a tcpdump on br0 (with or without promisc mode).
> 
> However, the IP code drops it in the beginning of ip_input.c/ip_rcv()
> as the dnat target did not update the skb->pkt_type. If after
> dnat'ing the packet is now destined to us then the skb->pkt_type
> needs to be updated from PACKET_OTHERHOST to PACKET_HOST, too.
> 
> Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
> ---
>  net/bridge/br_input.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 013f2290b..ec83175 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -198,8 +198,12 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>  	if (dst) {
>  		unsigned long now = jiffies;
>  
> -		if (dst->is_local)
> +		if (dst->is_local) {
> +			/* fix up potential DNAT mess */
> +			skb->pkt_type = PACKET_HOST;

I would like to find a way to fix this from ebtables itself, so we
don't need to add this code to the bridge core path. AFAICS, from
prerouting we don't know the dst yet, so we cannot know if this packet
is local from there.

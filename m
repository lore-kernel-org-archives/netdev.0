From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net] bridge: notify user space of fdb port
	change
Date: Wed, 14 May 2014 09:34:38 +0900
Message-ID: <5372BA1E.8000402@lab.ntt.co.jp>
References: <1399967708-7283-1-git-send-email-jmaxwell@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, jpirko@redhat.com, netdev@vger.kernel.org,
	jmaxwell@redhat.com, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Jon Maxwell <jmaxwell37@gmail.com>, stephen@networkplumber.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1399967708-7283-1-git-send-email-jmaxwell@redhat.com>
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

(2014/05/13 16:55), Jon Maxwell wrote:
> From: Jon Maxwell <jmaxwell37@gmail.com>
> 
> There has been a number incidents recently where customers running KVM have 
> reported that VM hosts on different Hypervisors are unreachable. Based on 
> pcap traces we found that the bridge was broadcasting the ARP request out 
> onto the network. However some NICs have an inbuilt switch which on occasions 
> were broadcasting the VMs ARP request back through the physical NIC on the 
> Hypervisor. This resulted in the bridge changing ports and incorrectly learning
> that the VMs mac address was external. As a result the ARP reply was directed 
> back onto the external network and VM never updated it's ARP cache. This patch 
> will notify the bridge command to identify such port toggling.
> 
> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
> ---
>  net/bridge/br_fdb.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 9203d5a..37742e2 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -507,6 +507,8 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>  					source->dev->name);
>  		} else {
>  			/* fastpath: update of existing entry */
> +			if (source->port_no != fdb->dst->port_no)

It seems that we don't need to fetch port_no and it is enough to compare
source and fdb->dst.

> +				fdb_notify(br, fdb, RTM_NEWNEIGH);
>  			fdb->dst = source;
>  			fdb->updated = jiffies;
>  			if (unlikely(added_by_user))
> 

This notifies fdb entry before updating existing entry. Is this on purpose?
I think we should notify the updated fdb entry.
Similar code fdb_add_entry() does after updating it.

Also, isn't it better to move update of dst into "if" block?

	if (source != fdb->dst) {
		fdb->dst = source;
		modified = true;
	}
	...
	if (modified) ...

Thanks,
Toshiaki Makita

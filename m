From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/6] net: bridge: break if
	__br_mdb_del fails
Date: Thu, 18 May 2017 16:45:32 +0300
Message-ID: <5d8f53ea-a9de-7c76-f088-48c5357cb2a2@cumulusnetworks.com>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
	<20170517212709.6473-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>,
	kernel@savoirfairelinux.com, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170517212709.6473-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
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

On 5/18/17 12:27 AM, Vivien Didelot wrote:
> Be symmetric with br_mdb_add and break if __br_mdb_del returns an error.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>   net/bridge/br_mdb.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
> index d20a01622b20..24eeeefb4179 100644
> --- a/net/bridge/br_mdb.c
> +++ b/net/bridge/br_mdb.c
> @@ -688,8 +688,9 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
>   		list_for_each_entry(v, &vg->vlan_list, vlist) {
>   			entry->vid = v->vid;
>   			err = __br_mdb_del(br, entry);
> -			if (!err)
> -				__br_mdb_notify(dev, p, entry, RTM_DELMDB);
> +			if (err)
> +				break;
> +			__br_mdb_notify(dev, p, entry, RTM_DELMDB);
>   		}
>   	} else {
>   		err = __br_mdb_del(br, entry);
> 

This can potentially break user-space scripts that rely on the best-effort
behaviour, this is the normal "delete without vid & enabled vlan filtering".
You can check the fdb delete code which does the same, this was intentional.

You can add an mdb entry without a vid to all vlans, add a vlan and then try
to remove it from all vlans where it is present - with this patch obviously
that will fail at the new vlan.

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 net-next] bridge: Fix incorrect judgment of
	promisc
Date: Thu, 05 Jun 2014 22:01:23 +0900
Message-ID: <53906A23.5040006@lab.ntt.co.jp>
References: <1401969212-19193-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<20140605123039.GA18310@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Laight <David.Laight@ACULAB.COM>,
	"David S . Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140605123039.GA18310@redhat.com>
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

(2014/06/05 21:30), Michael S. Tsirkin wrote:
> On Thu, Jun 05, 2014 at 08:53:32PM +0900, Toshiaki Makita wrote:
>> br_manage_promisc() incorrectly expects br_auto_port() to return only 0
>> or 1, while it actually returns flags, i.e., a subset of BR_AUTO_MASK.
>>
>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> ---
>>  net/bridge/br_if.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index a08d2b8..3eca3fd 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -153,7 +153,8 @@ void br_manage_promisc(struct net_bridge *br)
>>  			 * This lets us disable promiscuous mode and write
>>  			 * this config to hw.
>>  			 */
>> -			if (br->auto_cnt <= br_auto_port(p))
>> +			if (br->auto_cnt == 0 ||
>> +			    (br->auto_cnt == 1 && br_auto_port(p)))
>>  				br_port_clear_promisc(p);
>>  			else
>>  				br_port_set_promisc(p);
> 
> It's all a nasty side-effect of using macros IMHO.
> 
> How about we just make these inline functions returning bool?
> 
> The bugfix will fall out naturally.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Warning: untested.
> 
> 
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 53d6e32..5818dd2 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -200,8 +200,15 @@ struct net_bridge_port
>  #endif
>  };
>  
> -#define br_auto_port(p) ((p)->flags & BR_AUTO_MASK)
> -#define br_promisc_port(p) ((p)->flags & BR_PROMISC)
> +static inline bool br_auto_port(struct net_bridge_port *p)
> +{
> +	return p->flags & BR_AUTO_MASK;
> +}
> +
> +static inline bool br_promisc_port(struct net_bridge_port *p)
> +{
> +	return p->flags & BR_PROMISC;
> +}
>  
>  #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)

This also looks good.

IMHO, the caller side should not assume these macros (or inline
functions) return boolean value.  There exists similar macro such as
br_port_exists() that doesn't return boolean.

Ohterwise, we should change all macros into boolean functions, but it
might affect performance a little if such a macro is used in fast path?
(I'm worried about the cost of casting non-zero values into 1.)

Thanks,
Toshiaki Makita

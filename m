From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net] bridge: fix regression in ageing time
Date: Sat, 13 Feb 2016 23:35:05 +0200
Message-ID: <20160213213505.GC17193@colbert.idosch.org>
References: <20160212133109.218ed423@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, Scott Feldman <sfeldma@gmail.com>,
	Jouni Malinen <jouni@codeaurora.org>, David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160212133109.218ed423@xeon-e3>
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

Fri, Feb 12, 2016 at 11:31:09PM IST, stephen@networkplumber.org wrote:

Hi,

>This fixes a regression in the bridge ageing time caused by:
>
>commit c62987bbd8a1 ("bridge: push bridge setting ageing_time down to switchdev")
>
>There are users of Linux bridge which use the feature that if ageing time
>is set to 0 it causes entries to never expire.
>This feature is even listed on the web page:
>  https://www.linuxfoundation.org/collaborate/workgroups/networking/bridge
>
>For a pure software bridge, it is unnecessary for the code to have
>arbitrary restrictions on what values are allowable.
>
>Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
>---
>Please apply to 4.4 for stable as well.
>
> include/linux/if_bridge.h |    5 -----
> net/bridge/br_stp.c       |    9 ++++++---
> 2 files changed, 6 insertions(+), 8 deletions(-)
>
>--- a/include/linux/if_bridge.h	2015-09-23 16:17:25.387594110 -0700
>+++ b/include/linux/if_bridge.h	2016-02-11 07:49:35.016689397 -0800
>@@ -45,11 +45,6 @@ struct br_ip_list {
> #define BR_PROXYARP		BIT(8)
> #define BR_LEARNING_SYNC	BIT(9)
> #define BR_PROXYARP_WIFI	BIT(10)
>-
>-/* values as per ieee8021QBridgeFdbAgingTime */
>-#define BR_MIN_AGEING_TIME	(10 * HZ)

rocker is using this value:

vi drivers/net/ethernet/rocker/rocker.c +3707

>-#define BR_MAX_AGEING_TIME	(1000000 * HZ)
>-
> #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
> 
> extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
>--- a/net/bridge/br_stp.c	2015-12-17 17:17:18.650746679 -0800
>+++ b/net/bridge/br_stp.c	2016-02-11 07:49:53.240772672 -0800
>@@ -568,6 +568,12 @@ int br_set_max_age(struct net_bridge *br
> 
> }
> 
>+/* Set the how long dynamic forwarding database entries live.

Maybe drop the 'the'?

>+ * The Linux bridge allows values outside the standard 802.1
>+ * specification to allow for special cases:
>+ *   0 - means entry never age.

s/entry/entries/ ?

>+ *   1 - means entries disappear in next clock tick

Missing dot. ;)

>+ */
> int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
> {
> 	struct switchdev_attr attr = {
>@@ -579,9 +585,6 @@ int br_set_ageing_time(struct net_bridge
> 	unsigned long t = clock_t_to_jiffies(ageing_time);
> 	int err;
> 
>-	if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
>-		return -ERANGE;

Removing this and trying to set ageing time to 0 will cause mlxsw driver
to error out (firmware is checking for min value). I will send you a patch
for both rocker and mlxsw tomorrow, so that you can squash to yours and
do this change atomically.

Thanks for looking into this.

>-
> 	err = switchdev_port_attr_set(br->dev, &attr);
> 	if (err)
> 		return err;

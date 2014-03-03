From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC v3 4/6] bridge: enable root block during device
 registration
Date: Mon, 3 Mar 2014 15:43:30 -0800
Message-ID: <20140303154330.238a20bc@nehalam.linuxnetplumber.net>
References: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
	<1393886825-24323-5-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, mcgrof@suse.com,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1393886825-24323-5-git-send-email-mcgrof@do-not-panic.com>
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

On Mon,  3 Mar 2014 14:47:03 -0800
"Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:

> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> root block support was added via 1007dd1a on v3.8 but toggling
> this flag is only allowed after a device has been registered and
> added to a bridge as its a bridge *port* primitive, not a *net_device*
> feature. There are work arounds possible to account for the lack
> of netlink tools to toggle root_block, such as using the root_block
> syfs attribute [0] or using udev / the driver to set the MAC address
> to something high such as FE:FF:FF:FF:FF:FF, but neither of these
> ensure root block is respected _from_the_start_ through device
> initialization.
> 
> In order to support the root_block feature from the start since device
> initialization and in order to avoid having to require userspace
> work arounds to existing deployments this exposes a private
> net_device flag which enables drivers that know they want to
> start with the root_block feature enabled form the start. The
> only caveat with this is topologies that require STP or non-root
> will either have to use sysfs [0] or netlink tools like the
> iproute2 bridge util to toggle the flag off after initialization.
> This is an accepted compromise.
> 
> This flag is required given that ndo_add_slave() currently does not
> allow specifying any other parameters other than the net_device. We
> could extend this but in order to do that properly we'd need to
> evaluate all other types of master device implementations.
> 
> [0] echo 1 > /sys/devices/vif-2-0/net/vif2.0/brport/root_block
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: bridge@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org
> Cc: kvm@vger.kernel.org
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
>  include/linux/netdevice.h | 7 +++++++
>  net/bridge/br_if.c        | 2 ++
>  2 files changed, 9 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 1a86948..b17643a 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1181,6 +1181,11 @@ struct net_device_ops {
>   * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
>   *	change when it's running
>   * @IFF_MACVLAN: Macvlan device
> + * @IFF_BRIDGE_ROOT_BLOCK: don't consider this net_device for root port
> + *	when this interface is added to a bridge. This makes use of the
> + *	root_block mechanism but since its a bridge port primitive this
> + *	flag can be used to instantiate the preference to have root block
> + *	enabled from the start since initialization.
>   */

Doing this in priv flags bloats what is a limited resource (# of bits).
Plus there are issues (what if this is changed after adding to bridge)?

Maybe better to enhance existing netlink infrastructure to allow passing
flags on adding port to bridge.

Also, unless device is up, nothing will happen right away when added to bridge.
Root port status can be changed since device is disabled.

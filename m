From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/6] vxlan: check valid
 combinations of address scopes
Date: Fri, 14 Apr 2017 20:27:43 +0300
Message-ID: <0dd0812f-41d7-f4d8-2b40-0ff5b4553cf5@cogentembedded.com>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
	<49cd788f13c2cd3f6a42f34c219c9511cc1f9cec.1492187126.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, pshelar-LZ6Gd1LRuIk@public.gmane.org,
	aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <49cd788f13c2cd3f6a42f34c219c9511cc1f9cec.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/14/2017 07:44 PM, Matthias Schiffer wrote:

> * Multicast addresses are never valid as local address
> * Link-local IPv6 unicast addresses may only be used as remote when the
>   local address is link-local as well
> * Don't allow link-local IPv6 local/remote addresses without interface
>
> We also store in the flags field if link-local addresses are used for the
> follow-up patches that actually make VXLAN over link-local IPv6 work.
>
> Signed-off-by: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
> ---
>
> v2: was "vxlan: don't allow link-local IPv6 local/remote addresses without
> interface" before. v2 does a lot more checks and adds the
> VXLAN_F_IPV6_LINKLOCAL flag.
>
>  drivers/net/vxlan.c | 35 +++++++++++++++++++++++++++++++++++
>  include/net/vxlan.h |  2 ++
>  2 files changed, 37 insertions(+)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 07f89b037681..95a71546e8f2 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2881,11 +2881,39 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
>  	if (conf->saddr.sa.sa_family != conf->remote_ip.sa.sa_family)
>  		return -EINVAL;
>
> +	if (vxlan_addr_multicast(&conf->saddr))
> +		return -EINVAL;
> +
>  	if (conf->saddr.sa.sa_family == AF_INET6) {
>  		if (!IS_ENABLED(CONFIG_IPV6))
>  			return -EPFNOSUPPORT;
>  		use_ipv6 = true;
>  		conf->flags |= VXLAN_F_IPV6;
> +
> +		if (!(conf->flags & VXLAN_F_COLLECT_METADATA)) {
> +			int local_type =
> +				ipv6_addr_type(&conf->saddr.sin6.sin6_addr);
> +			int remote_type =
> +				ipv6_addr_type(&conf->remote_ip.sin6.sin6_addr);
> +
> +			if (local_type & IPV6_ADDR_LINKLOCAL) {
> +				if (!(remote_type & IPV6_ADDR_LINKLOCAL) &&
> +				    (remote_type != IPV6_ADDR_ANY)) {
> +					pr_info("invalid combination of address scopes\n");

    Maybe pr_err()?

> +					return -EINVAL;
> +				}
> +
> +				conf->flags |= VXLAN_F_IPV6_LINKLOCAL;
> +			} else {
> +				if (remote_type ==
> +				    (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL)) {
> +					pr_info("invalid combination of address scopes\n");

    Here as well...

> +					return -EINVAL;
> +				}
> +
> +				conf->flags &= ~VXLAN_F_IPV6_LINKLOCAL;
> +			}
> +		}
>  	}
>
>  	if (conf->label && !use_ipv6) {
[...]

MBR, Sergei

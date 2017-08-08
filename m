From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] openvswitch: add NSH support
Date: Tue, 8 Aug 2017 16:28:10 +0200
Message-ID: <20170808162810.1bab3812@griffin>
References: <1502168380-106785-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, davem@davemloft.net
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751880AbdHHO2N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 10:28:13 -0400
In-Reply-To: <1502168380-106785-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  8 Aug 2017 12:59:40 +0800, Yi Yang wrote:
> +struct ovs_key_nsh {
> +	__u8 flags;
> +	__u8 mdtype;
> +	__u8 np;
> +	__u8 pad;
> +	__be32 path_hdr;
> +	__be32 c[4];

"c" is a very poor name. Please rename it to something that expresses
what this field contains.

Also, this looks like MD type 1 only. How are those fields going to work
with MD type 2? I don't think MD type 2 implementation is necessary in
this patch but I'd like to know how this is going to work - it's uAPI
and thus set in stone once this is merged. The uAPI needs to be
designed with future use in mind.

> +#define OVS_ENCAP_NSH_MAX_MD_LEN 16
> +/*
> + * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
> + * @flags: NSH header flags.
> + * @mdtype: NSH metadata type.
> + * @mdlen: Length of NSH metadata in bytes.
> + * @np: NSH next_protocol: Inner packet type.
> + * @path_hdr: NSH service path id and service index.
> + * @metadata: NSH metadata for MD type 1 or 2
> + */
> +struct ovs_action_encap_nsh {
> +	__u8 flags;
> +	__u8 mdtype;
> +	__u8 mdlen;
> +	__u8 np;
> +	__be32 path_hdr;
> +	__u8 metadata[OVS_ENCAP_NSH_MAX_MD_LEN];

This is wrong. The metadata size is set to a fixed size by this and
cannot be ever extended, or at least not easily. Netlink has attributes
for exactly these cases and that's what needs to be used here.

> @@ -835,6 +866,8 @@ enum ovs_action_attr {
>  	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
>  	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
>  	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
> +	OVS_ACTION_ATTR_ENCAP_NSH,    /* struct ovs_action_encap_nsh. */
> +	OVS_ACTION_ATTR_DECAP_NSH,    /* No argument. */

Use "push" and "pop", not "encap" and "decap" to be consistent with the
naming in the rest of the file. We use encap and decap for tunnel
operations. This code does not use lwtunnels, thus push and pop is more
appropriate.

 Jiri

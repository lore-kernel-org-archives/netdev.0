From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 09/11] net: dsa: Move FDB dump implementation inside DSA
Date: Tue, 18 Jul 2017 14:06:00 -0400
Message-ID: <877ez5boxj.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com> <1500387624-4361-10-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53094 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdGRSIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 14:08:43 -0400
In-Reply-To: <1500387624-4361-10-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arkadi,

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> +typedef int dsa_fdb_dump_cb_t(const unsigned char *addr, u16 vid,
> +			      u16 ndm_state, void *data);

Can I ask you to change u16 ndm_state for bool is_static at the same
time? Ethernet switches do not need to report more than that.

> +static int
> +dsa_slave_port_fdb_do_dump(const unsigned char *addr, u16 vid,
> +			   u16 ndm_state, void *data)
> +{
> +	struct dsa_slave_dump_ctx *dump = data;
> +	u32 portid = NETLINK_CB(dump->cb->skb).portid;
> +	u32 seq = dump->cb->nlh->nlmsg_seq;
> +	struct nlmsghdr *nlh;
> +	struct ndmsg *ndm;
> +
> +	if (dump->idx < dump->cb->args[2])
> +		goto skip;
> +
> +	nlh = nlmsg_put(dump->skb, portid, seq, RTM_NEWNEIGH,
> +			sizeof(*ndm), NLM_F_MULTI);
> +	if (!nlh)
> +		return -EMSGSIZE;
> +
> +	ndm = nlmsg_data(nlh);
> +	ndm->ndm_family  = AF_BRIDGE;
> +	ndm->ndm_pad1    = 0;
> +	ndm->ndm_pad2    = 0;
> +	ndm->ndm_flags   = NTF_SELF;
> +	ndm->ndm_type    = 0;
> +	ndm->ndm_ifindex = dump->dev->ifindex;
> +	ndm->ndm_state   = ndm_state;

So we can simply scope this here:

        ndm->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;

> +
> +	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, addr))
> +		goto nla_put_failure;
> +
> +	if (vid && nla_put_u16(dump->skb, NDA_VLAN, vid))
> +		goto nla_put_failure;
> +
> +	nlmsg_end(dump->skb, nlh);
> +
> +skip:
> +	dump->idx++;
> +	return 0;
> +
> +nla_put_failure:
> +	nlmsg_cancel(dump->skb, nlh);
> +	return -EMSGSIZE;
> +}

Other than that, LGTM.


Thanks,

        Vivien

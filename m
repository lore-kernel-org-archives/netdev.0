From: Ulrich Weber <uweber@astaro.de>
Subject: Re: [Vpn-failover] [RFC] IPSEC failover - Netlink part
Date: Mon, 08 Nov 2004 11:31:21 +0100
Message-ID: <418F4AF9.7050605@astaro.de>
References: <1099045435.2888.47.camel@nienna.balabit> <418A3630.1040900@astaro.de> <418A71DA.2090607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vpn-failover@lists.balabit.hu, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418A71DA.2090607@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

what did you mean with "leaks xfrm_state reference"? The missing
xfrm_state_put(x) ?
I changed it (see below) to use Krisztian's xfrm_state_replay_update function.

|>
|> +    struct xfrm_replay_state *replay;
|> + +    x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
|> +        if (x == NULL) {
|> +        printk(KERN_INFO "Found no xfrm state for sa seq update\n");
|> +                return -ESRCH;
|> +        }
|> +
|> +    if(xfrma[XFRMA_REPLAY-1]) {
|> +        replay = RTA_DATA(xfrma[XFRMA_REPLAY - 1]);
|> +        x->replay = *replay;
|>
|>
|> +        }
|> +    else return -EINVAL;
|>
|>
| ^^ leaks xfrm_state reference
|
|> +
|> +    return 0;
|>
|>
| ^^ same here
|
|> +} +
|> static const int xfrm_msg_min[(XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)] = {
|>     NLMSG_LENGTH(sizeof(struct xfrm_usersa_info)),    /* NEW SA */
|>     NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),    /* DEL SA */
|> @@ -867,6 +897,7 @@
|>     NLMSG_LENGTH(sizeof(struct xfrm_user_polexpire)), /* POLEXPIRE */
|>     NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush)),    /* FLUSH SA */
|>     NLMSG_LENGTH(0),                /* FLUSH POLICY */
|> +    NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),/* UPD SEQ */
|>
|>
| ^^ what about struct xfrm_replay_state ?
it's attached as rt attribute, so it should be ok.

- ---
static int xfrm_update_seq(struct sk_buff *skb, struct nlmsghdr *nlh, void
**xfrma)
{
~        struct xfrm_state *x;
~        struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
~        struct xfrm_replay_state *replay;

~        x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
~        if (x == NULL) {
~                printk(KERN_INFO "Found no xfrm state for sa seq update\n");
~                return -ESRCH;
~                }

~        if(xfrma[XFRMA_REPLAY-1]) {
~                replay = RTA_DATA(xfrma[XFRMA_REPLAY - 1]);
~                xfrm_state_replay_update(x, replay);
~                xfrm_state_put(x);
~                }
~        else return -EINVAL;

~        return 0;
}


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBj0r522t2oTuElzoRAgBWAKCKSQXB2rX9DeMpMwVIMl9mXfmxUQCfeYYY
1d3V4P8C3+d5YgsYpwkFHPQ=
=RihP
-----END PGP SIGNATURE-----

From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC] netlink: netlink_ack send a capped message in case of error
Date: Sun, 23 Aug 2015 20:27:06 -0700
Message-ID: <CAE4R7bAYUhbUoGK_M=USJW8pgWmBrKsNuzLFmY70aBzti53Vxg@mail.gmail.com>
References: <1440367577-15786-1-git-send-email-christophe-h.ricard@st.com> <1440367577-15786-2-git-send-email-christophe-h.ricard@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, jbenc@redhat.com,
	sameo@linux.intel.com, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Christophe Ricard <christophe-h.ricard@st.com>
To: Christophe Ricard <christophe.ricard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36613 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbbHXD10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 23:27:26 -0400
Received: by obkg7 with SMTP id g7so102204316obk.3
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 20:27:26 -0700 (PDT)
In-Reply-To: <1440367577-15786-2-git-send-email-christophe-h.ricard@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 23, 2015 at 3:06 PM, Christophe Ricard
<christophe.ricard@gmail.com> wrote:
> Currently, ACK in case of error contains a full copy of the originating
> message. This can cause lost ACKs with large netlink messages, especially
> after commit c05cdb1b864f ("netlink: allow large data transfers from
> user-space").
>
> Send back a capped message instead.
>
> Signed-off-by: Christophe Ricard <christophe-h.ricard@st.com>
> ---
>  net/netlink/af_netlink.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 67d2104..9df862c 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -85,6 +85,9 @@ struct listeners {
>  #define NETLINK_F_RECV_NO_ENOBUFS      0x8
>  #define NETLINK_F_LISTEN_ALL_NSID      0x10
>
> +/* Arbitrary value for a small message less than PAGE_SIZE */
> +#define NETLINK_ERR_MESSAGE_CAP        128
> +
>  static inline int netlink_is_kernel(struct sock *sk)
>  {
>         return nlk_sk(sk)->flags & NETLINK_F_KERNEL_SOCKET;
> @@ -2873,10 +2876,15 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
>         struct nlmsghdr *rep;
>         struct nlmsgerr *errmsg;
>         size_t payload = sizeof(*errmsg);
> +       size_t size = 0;
>
> -       /* error messages get the original request appened */
> -       if (err)
> -               payload += nlmsg_len(nlh);
> +       /* error messages get a cap request appened */
> +       if (err) {
> +               payload += nlmsg_len(nlh) > NETLINK_ERR_MESSAGE_CAP ?
> +                          NETLINK_ERR_MESSAGE_CAP : nlmsg_len(nlh);
> +               size = nlmsg_len(nlh) > NETLINK_ERR_MESSAGE_CAP ?
> +                     (NETLINK_ERR_MESSAGE_CAP + NLMSG_HDRLEN) : nlh->nlmsg_len;
> +       }

This arbitrary cap can truncate the msg at unfortunate boundaries,
leaving nests open or slicing a TLV attr in half.  So the receiver app
now needs to handle those cases or ignore the payload.  But if
ignoring the payload, might as well not include the payload in the
first place, using the flag idea talked about earlier.

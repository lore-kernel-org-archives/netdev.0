From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 5/5] geneve: add initial netdev driver for GENEVE tunnels
Date: Fri, 8 May 2015 16:19:28 -0700
Message-ID: <CAEP_g=-=GEZn+Q48=OdWVNHSONf9EVfcz3PGE2qR4ynWXbsHeQ@mail.gmail.com>
References: <1431105657-25492-1-git-send-email-linville@tuxdriver.com> <1431105657-25492-6-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:47760 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751378AbbEHXTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 19:19:49 -0400
Received: by mail-yk0-f180.google.com with SMTP id c202so24296392yke.2
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 16:19:48 -0700 (PDT)
In-Reply-To: <1431105657-25492-6-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 10:20 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> new file mode 100644
> index 000000000000..102030de1d45
> --- /dev/null
> +++ b/drivers/net/geneve.c
> +/* geneve receive/decap routine */
> +static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
[...]
> +       /* Find the device for this VNI */
> +       hash = geneve_net_vni_hash(gnvh->vni);
> +       vni_list_head = &gn->vni_list[hash];
> +       hlist_for_each_entry_rcu(dummy, vni_list_head, hlist) {
> +               if (!memcmp(gnvh->vni, dummy->vni, sizeof(dummy->vni)) &&
> +                   iph->saddr == dummy->remote.sin_addr.s_addr)
> +                       geneve = dummy;

I guess we might as well break out of the loop at this point rather
than keep searching.

> +static int geneve_newlink(struct net *net, struct net_device *dev,
> +                        struct nlattr *tb[], struct nlattr *data[])
> +{
[...]
> +       if (!data[IFLA_GENEVE_ID])
> +               return -EINVAL;

Should we enforce that IFLA_GENEVE_REMOTE is present? Otherwise, it's
not clear what we would do without it.

[...]
> +       list_add(&geneve->next, &gn->geneve_list);
> +
> +       geneve_net_vni_add(gn, hash, geneve);

The locking seems a bit inconsistent for these two pieces - they are
accessed in the same places but one has a special lock and the other
doesn't. I think the answer is that neither needs a lock because they
are both protected by RTNL but it made me pause.

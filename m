From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] ovs: queue_userspace_packet: bail out if nla_nest_start
 returns NULL
Date: Wed, 3 Jul 2013 09:32:55 -0700
Message-ID: <CAEP_g=84532Nh1wagsifOaBkCDk5eOUtG=RzWSv_Z+tPxzUOGg@mail.gmail.com>
References: <1372841397-10873-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:55062 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932202Ab3GCQdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 12:33:15 -0400
Received: by mail-ie0-f174.google.com with SMTP id 9so896544iec.5
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 09:33:15 -0700 (PDT)
In-Reply-To: <1372841397-10873-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 3, 2013 at 1:49 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> The return value of nla_nest_start() is not checked, and can be NULL,
> which is then being dereferenced in nla_nest_end(). Add a check to
> prevent such situations.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  On top of "net-next" tree.
>
>  net/openvswitch/datapath.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index d12d6b8..51a3c66 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -427,6 +427,10 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
>         upcall->dp_ifindex = dp_ifindex;
>
>         nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
> +       if (unlikely(!nla)) {
> +               err = -ENOMEM;
> +               goto out;
> +       }

nla_nest_start() doesn't allocate any memory, it only fails if there
isn't enough space, so the correct error code would be -EMSGSIZE.
However, we just calculated the correct size a few lines earlier and
we don't double check the size anywhere else, so this doesn't make a
lot of sense to me.

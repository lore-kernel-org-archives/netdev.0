From: Mihai Maruseac <mmaruseac@ixiacom.com>
Subject: Re: /proc/net/dev is funky in 3.3.0
Date: Tue, 3 Apr 2012 10:17:26 +0300
Message-ID: <CAOMsUMLhfZ_nopcU1otBS+yiUzjNNYq5YewaYw_-JdhetBubpw@mail.gmail.com>
References: <4F7A7C98.1030103@candelatech.com> <1333431810.18626.37.camel@edumazet-glaptop>
 <4F7A905B.3080107@candelatech.com> <1333434995.18626.39.camel@edumazet-glaptop>
 <1333436789.18626.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>,
	Mihai Maruseac <mmaruseac@ixiacom.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:59611 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447Ab2DCHRq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 03:17:46 -0400
Received: by iagz16 with SMTP id z16so5223927iag.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 00:17:46 -0700 (PDT)
In-Reply-To: <1333436789.18626.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 3, 2012 at 10:06 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Tue, 2012-04-03 at 08:36 +0200, Eric Dumazet wrote:
>
>> Hmm, I think I understand, commit f04565ddf52 added a regression her=
e, I
>> will send a fix.
>>
>
> If you want to try following patch, please do so, I cant try it right
> now...
>
> I'll provide a proper changelog/attributions in a couple of hours, an=
d
> make tests myself of course.
>
> Thanks
>
> =A0net/core/dev.c | =A0 46 ++++++++++++------------------------------=
----
> =A01 file changed, 12 insertions(+), 34 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6c7dc9d..f7e7de3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4028,54 +4028,45 @@ static int dev_ifconf(struct net *net, char _=
_user *arg)
>
> =A0#ifdef CONFIG_PROC_FS
>
> -#define BUCKET_SPACE (32 - NETDEV_HASHBITS)
> +#define BUCKET_SPACE (32 - NETDEV_HASHBITS - 1)
>
> =A0struct dev_iter_state {
> =A0 =A0 =A0 =A0struct seq_net_private p;
> - =A0 =A0 =A0 unsigned int pos; /* bucket << BUCKET_SPACE + offset */
> =A0};
>
> =A0#define get_bucket(x) ((x) >> BUCKET_SPACE)
> =A0#define get_offset(x) ((x) & ((1 << BUCKET_SPACE) - 1))
> =A0#define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
>
> -static inline struct net_device *dev_from_same_bucket(struct seq_fil=
e *seq)
> +static inline struct net_device *dev_from_same_bucket(struct seq_fil=
e *seq, loff_t *pos)
> =A0{
> - =A0 =A0 =A0 struct dev_iter_state *state =3D seq->private;
> =A0 =A0 =A0 =A0struct net *net =3D seq_file_net(seq);
> =A0 =A0 =A0 =A0struct net_device *dev;
> =A0 =A0 =A0 =A0struct hlist_node *p;
> =A0 =A0 =A0 =A0struct hlist_head *h;
> - =A0 =A0 =A0 unsigned int count, bucket, offset;
> + =A0 =A0 =A0 unsigned int count =3D 0, offset =3D get_offset(*pos);
>
> - =A0 =A0 =A0 bucket =3D get_bucket(state->pos);
> - =A0 =A0 =A0 offset =3D get_offset(state->pos);
> - =A0 =A0 =A0 h =3D &net->dev_name_head[bucket];
> - =A0 =A0 =A0 count =3D 0;
> + =A0 =A0 =A0 h =3D &net->dev_name_head[get_bucket(*pos)];
> =A0 =A0 =A0 =A0hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (count++ =3D=3D offset) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->pos =3D set_buck=
et_offset(bucket, count);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (++count =3D=3D offset)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return dev;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return NULL;
> =A0}
>
> -static inline struct net_device *dev_from_new_bucket(struct seq_file=
 *seq)
> +static inline struct net_device *dev_from_bucket(struct seq_file *se=
q, loff_t *pos)
> =A0{
> - =A0 =A0 =A0 struct dev_iter_state *state =3D seq->private;
> =A0 =A0 =A0 =A0struct net_device *dev;
> =A0 =A0 =A0 =A0unsigned int bucket;
>
> - =A0 =A0 =A0 bucket =3D get_bucket(state->pos);
> =A0 =A0 =A0 =A0do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev =3D dev_from_same_bucket(seq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev =3D dev_from_same_bucket(seq, pos);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return dev;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bucket++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->pos =3D set_bucket_offset(bucket=
, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bucket =3D get_bucket(*pos);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *pos =3D set_bucket_offset(bucket + 1, =
1);
> =A0 =A0 =A0 =A0} while (bucket < NETDEV_HASHENTRIES);
>
> =A0 =A0 =A0 =A0return NULL;
> @@ -4088,33 +4079,20 @@ static inline struct net_device *dev_from_new=
_bucket(struct seq_file *seq)
> =A0void *dev_seq_start(struct seq_file *seq, loff_t *pos)
> =A0 =A0 =A0 =A0__acquires(RCU)
> =A0{
> - =A0 =A0 =A0 struct dev_iter_state *state =3D seq->private;
> -
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0if (!*pos)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return SEQ_START_TOKEN;
>
> - =A0 =A0 =A0 /* check for end of the hash */
> - =A0 =A0 =A0 if (state->pos =3D=3D 0 && *pos > 1)
> + =A0 =A0 =A0 if (get_bucket(*pos) >=3D NETDEV_HASHENTRIES)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
> - =A0 =A0 =A0 return dev_from_new_bucket(seq);
> + =A0 =A0 =A0 return dev_from_bucket(seq, pos);
> =A0}
>
> =A0void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> =A0{
> - =A0 =A0 =A0 struct net_device *dev;
> -
> =A0 =A0 =A0 =A0++*pos;
> -
> - =A0 =A0 =A0 if (v =3D=3D SEQ_START_TOKEN)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev_from_new_bucket(seq);
> -
> - =A0 =A0 =A0 dev =3D dev_from_same_bucket(seq);
> - =A0 =A0 =A0 if (dev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev;
> -
> - =A0 =A0 =A0 return dev_from_new_bucket(seq);
> + =A0 =A0 =A0 return dev_from_bucket(seq, pos);
> =A0}
>
> =A0void dev_seq_stop(struct seq_file *seq, void *v)
>

Looks good to me.

Thanks Eric,
Mihai

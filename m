From: Mihai Maruseac <mmaruseac@ixiacom.com>
Subject: Re: [PATCH] net/core: Fix seeking in /proc/net/dev
Date: Fri, 6 Apr 2012 20:14:20 +0300
Message-ID: <CAOMsUMLDFpYw9REPjZd2m49xV4UKFjFobNorGmOPCFeqjV-RDg@mail.gmail.com>
References: <1333731944-15808-1-git-send-email-john@keeping.me.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mihai Maruseac <mihai.maruseac@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: John Keeping <john@keeping.me.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333731944-15808-1-git-send-email-john@keeping.me.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 8:05 PM, John Keeping <john@keeping.me.uk> wrote=
:
> Commit f04565ddf52e4 (dev: use name hash for dev_seq_ops) introduced
> code that fails to check the requested position when getting an item =
for
> /proc/net/dev. =A0This means that any code which seeks within this fi=
le is
> likely to receive corrupted data.
>
> A test case for this is to use the read builtin in bash:
>
> $ while read line; do echo "$line"; done </proc/net/dev | cut -c-20
> Inter-| =A0 Receive
> face |bytes =A0 =A0packe
> virbr0: =A0 20706
> 0
> lo: 2329335 =A0 10305
> eth0: =A0 =A0 =A0 0
>
> compared to just cat'ing the file:
>
> $ cat /proc/net/dev | cut -c-20
> Inter-| =A0 Receive
> =A0face |bytes =A0 =A0pack
> =A0 =A0lo: 2329335 =A0 10
> virbr0: =A0 20706
> =A0sit0: =A0 =A0 =A0 0
> =A0wlan0: 1727234745 1
> =A0eth0: =A0 =A0 =A0 0
>
> This patch takes the sledgehammer approach of starting again from the
> beginning if asked to seek backwards.
>
> Signed-off-by: John Keeping <john@keeping.me.uk>
>
> ---
> I have made the minimal change required to fix the bug here. =A0If de=
sired I
> can spend some more time and enhance the dev_from_new_bucket and
> dev_from_same_bucket functions to support walking backwards as well a=
s
> forwards through the items in the table.
>
> ---
> =A0net/core/dev.c | =A0 24 +++++++++++++++++++-----
> =A01 files changed, 19 insertions(+), 5 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6ca32f6..66b1e891 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4040,6 +4040,7 @@ static int dev_ifconf(struct net *net, char __u=
ser *arg)
>
> =A0struct dev_iter_state {
> =A0 =A0 =A0 =A0struct seq_net_private p;
> + =A0 =A0 =A0 loff_t expected_pos; /* current index */
> =A0 =A0 =A0 =A0unsigned int pos; /* bucket << BUCKET_SPACE + offset *=
/
> =A0};
>
> @@ -4096,24 +4097,37 @@ static inline struct net_device *dev_from_new=
_bucket(struct seq_file *seq)
> =A0void *dev_seq_start(struct seq_file *seq, loff_t *pos)
> =A0 =A0 =A0 =A0__acquires(RCU)
> =A0{
> + =A0 =A0 =A0 struct net_device *dev;
> =A0 =A0 =A0 =A0struct dev_iter_state *state =3D seq->private;
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> - =A0 =A0 =A0 if (!*pos)
> + =A0 =A0 =A0 if (!*pos) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->expected_pos =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->pos =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return SEQ_START_TOKEN;
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 /* check for end of the hash */
> - =A0 =A0 =A0 if (state->pos =3D=3D 0 && *pos > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 /* If we're asked for something behind where we are, st=
art again. */
> + =A0 =A0 =A0 if (state->expected_pos >=3D *pos) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->expected_pos =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->pos =3D 0;
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 return dev_from_new_bucket(seq);
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev =3D dev_from_new_bucket(seq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++state->expected_pos;
> + =A0 =A0 =A0 } while (dev && state->expected_pos < *pos);
> +
> + =A0 =A0 =A0 return dev;
> =A0}
>
> =A0void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *dev;
> + =A0 =A0 =A0 struct dev_iter_state *state =3D seq->private;
>
> =A0 =A0 =A0 =A0++*pos;
> + =A0 =A0 =A0 state->expected_pos =3D *pos;
>
> =A0 =A0 =A0 =A0if (v =3D=3D SEQ_START_TOKEN)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return dev_from_new_bucket(seq);
> --
> 1.7.8.5
>

Looks good to me. However, Eric just submitted a patch here with other
changes caused by a logic error in the original patch.

Now I understand why those resets to the beginning were there (though
they are very rare)

From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH 2/4] drivers/net/ethernet/dec/tulip: Add tulip_ prefix to set_bit_le()
Date: Mon, 11 Jun 2012 08:42:45 -0700
Message-ID: <CAP6odjjPAo+y_oZzBVFbOPVn=KkX-Oqycvkjo4CdNuUzNN4zkA@mail.gmail.com>
References: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp>
	<20120611213002.caaf0e05.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grundler@parisc-linux.org, bhutchings@solarflare.com,
	arnd@arndb.de, avi@redhat.com, mtosatti@redhat.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	kvm@vger.kernel.org, takuya.yoshikawa@gmail.com
To: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120611213002.caaf0e05.yoshikawa.takuya@oss.ntt.co.jp>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 11, 2012 at 5:30 AM, Takuya Yoshikawa
<yoshikawa.takuya@oss.ntt.co.jp> wrote:
> From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
>
> Needed to introduce generic set_bit_le().
>
> Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
> Cc: Grant Grundler <grundler@parisc-linux.org>
> ---
> =A0drivers/net/ethernet/dec/tulip/de2104x.c =A0 =A0| =A0 =A07 +++----
> =A0drivers/net/ethernet/dec/tulip/tulip_core.c | =A0 =A07 +++----
> =A02 files changed, 6 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/e=
thernet/dec/tulip/de2104x.c
> index 61cc093..e635f1a 100644
> --- a/drivers/net/ethernet/dec/tulip/de2104x.c
> +++ b/drivers/net/ethernet/dec/tulip/de2104x.c
> @@ -661,8 +661,7 @@ static netdev_tx_t de_start_xmit (struct sk_buff =
*skb,
> =A0 =A0new frame, not around filling de->setup_frame. =A0This is non-=
deterministic
> =A0 =A0when re-entered but still correct. */
>
> -#undef set_bit_le
> -#define set_bit_le(i,p) do { ((char *)(p))[(i)/8] |=3D (1<<((i)%8));=
 } while(0)
> +#define tulip_set_bit_le(i,p) do { ((char *)(p))[(i)/8] |=3D (1<<((i=
)%8)); } while(0)

I am ok with this patch going in. This code predates the clear
understanding of bit_ops that we have now and will continue to work
with this patch.

If you have time to follow Arnd's suggestion to use __set_bit_le()
(and removing both local definitions), that would be better. Either
way:

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks!
grant

>
> =A0static void build_setup_frame_hash(u16 *setup_frm, struct net_devi=
ce *dev)
> =A0{
> @@ -673,12 +672,12 @@ static void build_setup_frame_hash(u16 *setup_f=
rm, struct net_device *dev)
> =A0 =A0 =A0 =A0u16 *eaddrs;
>
> =A0 =A0 =A0 =A0memset(hash_table, 0, sizeof(hash_table));
> - =A0 =A0 =A0 set_bit_le(255, hash_table); =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0/* Broadcast entry */
> + =A0 =A0 =A0 tulip_set_bit_le(255, hash_table); =A0 =A0 =A0 =A0 =A0 =
=A0 =A0/* Broadcast entry */
> =A0 =A0 =A0 =A0/* This should work on big-endian machines as well. */
> =A0 =A0 =A0 =A0netdev_for_each_mc_addr(ha, dev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int index =3D ether_crc_le(ETH_ALEN, h=
a->addr) & 0x1ff;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit_le(index, hash_table);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tulip_set_bit_le(index, hash_table);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < 32; i++) {
> diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/ne=
t/ethernet/dec/tulip/tulip_core.c
> index c4f37ac..3a1ebd02 100644
> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
> @@ -1010,8 +1010,7 @@ static int private_ioctl (struct net_device *de=
v, struct ifreq *rq, int cmd)
> =A0 =A0new frame, not around filling tp->setup_frame. =A0This is non-=
deterministic
> =A0 =A0when re-entered but still correct. */
>
> -#undef set_bit_le
> -#define set_bit_le(i,p) do { ((char *)(p))[(i)/8] |=3D (1<<((i)%8));=
 } while(0)
> +#define tulip_set_bit_le(i,p) do { ((char *)(p))[(i)/8] |=3D (1<<((i=
)%8)); } while(0)
>
> =A0static void build_setup_frame_hash(u16 *setup_frm, struct net_devi=
ce *dev)
> =A0{
> @@ -1022,12 +1021,12 @@ static void build_setup_frame_hash(u16 *setup=
_frm, struct net_device *dev)
> =A0 =A0 =A0 =A0u16 *eaddrs;
>
> =A0 =A0 =A0 =A0memset(hash_table, 0, sizeof(hash_table));
> - =A0 =A0 =A0 set_bit_le(255, hash_table); =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0/* Broadcast entry */
> + =A0 =A0 =A0 tulip_set_bit_le(255, hash_table); =A0 =A0 =A0 =A0 =A0 =
=A0 =A0/* Broadcast entry */
> =A0 =A0 =A0 =A0/* This should work on big-endian machines as well. */
> =A0 =A0 =A0 =A0netdev_for_each_mc_addr(ha, dev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int index =3D ether_crc_le(ETH_ALEN, h=
a->addr) & 0x1ff;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit_le(index, hash_table);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tulip_set_bit_le(index, hash_table);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0for (i =3D 0; i < 32; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*setup_frm++ =3D hash_table[i];
> --
> 1.7.5.4
>

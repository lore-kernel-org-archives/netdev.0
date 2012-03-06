From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [Xen-devel] [PATCH 0001/001] xen: multi page ring support for
	block devices
Date: Tue, 6 Mar 2012 12:20:46 -0500
Message-ID: <CAPbh3rsExLtohBwVd_scYuO=GN1iZE5egQQ3x5M59YUno5Rtyw@mail.gmail.com>
References: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
	<7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
Reply-To: konrad@darnok.org
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "jeremy@goop.org" <jeremy@goop.org>, Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"waldi@debian.org" <waldi@debian.org>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>,
	"joe.jin@oracle.com" <joe.jin@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jbeulich@novell.com" <jbeulich@novell.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dgdegra@tycho.nsa.gov" <dgdegra@tycho.nsa.gov>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"lersek@redhat.com" <lersek@redhat.com>,
	"akpm@linux-fo
To: Santosh Jodh <Santosh.Jodh@citrix.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 5, 2012 at 4:49 PM, Santosh Jodh <Santosh.Jodh@citrix.com> wrot=
e:
> From: Santosh Jodh <santosh.jodh@citrix.com>
>
> Add support for multi page ring for block devices.
> The number of pages is configurable for blkback via module parameter.
> blkback reports max-ring-page-order to blkfront via xenstore.
> blkfront reports its supported ring-page-order to blkback via xenstore.
> blkfront reports multi page ring references via ring-refNN in xenstore.
> The change allows newer blkfront to work with older blkback and
> vice-versa.
> Based on original patch by Paul Durrant.

you should include his SoB in this patch.

The patch overall looks Ok, thought I do have some comments:

 -> the call to "xenbus_ring_ops_init();" looks like a bug-fix? If so,
it should be a separate patch.
 -> the usage of XenbusStateInitWait? Why do we introduce that? Looks
like a fix to something.
-> XENBUS_MAX_RING_PAGES - why 2? Why not 4? What is the optimal
default size for SSD usage? 16?
 -> don't do sprintf, use snprinf
 -> don't use printk(KERN_..), use pr_info or the variant of
pr_err,pr_debug, etc.
 -> don't split the printk contents. It is Ok for them to be more than
80 lines.
 -> check that xen_blkif_ring_order is under XENBUS_MAX_RING_PAGES.
Otherwise a joker could do =3D 9999999999999999999 for ring size and we
would try to use that.
 -> Separate the patch that introduces the changes to the XenBus
infrastructure (and then the changes to net* and blk*) to use the
extra arguments would be folded in that patch. Then the patch that
implements the multi ring to blkback is a patch that depends on that
the XenBus modifications patch. Also make sure you CC David Miller and
Jens Axboe on the XenBus patch as it modifies the net-* side which
requires Ian's and David's Ack.
 -> Have you done a sanity/test check where the backend and frontend
have different size rings? Just to make sure nothing explodes.

>
> Signed-off-by: Santosh Jodh <santosh.jodh@citrix.com>
> ---
> diff --git a/drivers/block/xen-blkback/blkback.c b/drivers/block/xen-blkb=
ack/blkback.c
> index 0088bf6..72f2e18 100644
> --- a/drivers/block/xen-blkback/blkback.c
> +++ b/drivers/block/xen-blkback/blkback.c
> @@ -60,6 +60,39 @@ static int xen_blkif_reqs =3D 64;
> =A0module_param_named(reqs, xen_blkif_reqs, int, 0);
> =A0MODULE_PARM_DESC(reqs, "Number of blkback requests to allocate");
>
> +/* Order of maximum shared ring size advertised to the front end. */
> +int xen_blkif_max_ring_order =3D XENBUS_MAX_RING_ORDER;
> +
> +#define BLK_RING_SIZE(_order) __CONST_RING_SIZE(blkif, PAGE_SIZE << (_or=
der))
> +
> +static int set_max_ring_order(const char *buf, struct kernel_param *kp)
> +{
> + =A0 =A0 =A0 int err;
> + =A0 =A0 =A0 unsigned long order;
> +
> + =A0 =A0 =A0 err =3D kstrtol(buf, 0, &order);
> + =A0 =A0 =A0 if (err ||
> + =A0 =A0 =A0 =A0 =A0 order < 0 ||
> + =A0 =A0 =A0 =A0 =A0 order > XENBUS_MAX_RING_ORDER)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 if (xen_blkif_reqs < BLK_RING_SIZE(order))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING "WARNING: "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"I/O request space (%d reqs)=
 < ring order %ld, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"consider increasing %s.reqs=
 to >=3D %ld.",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xen_blkif_reqs, order, KBUIL=
D_MODNAME,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0roundup_pow_of_two(BLK_RING_=
SIZE(order)));
> +
> + =A0 =A0 =A0 xen_blkif_max_ring_order =3D order;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +module_param_call(max_ring_order,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_max_ring_order, param_get_int,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &xen_blkif_max_ring_order, 0644);
> +MODULE_PARM_DESC(max_ring_order, "log2 of maximum ring size, in pages.");
> +
> =A0/* Run-time switchable: /sys/module/blkback/parameters/ */
> =A0static unsigned int log_stats;
> =A0module_param(log_stats, int, 0644);
> diff --git a/drivers/block/xen-blkback/common.h b/drivers/block/xen-blkba=
ck/common.h
> index d0ee7ed..5f33a1a 100644
> --- a/drivers/block/xen-blkback/common.h
> +++ b/drivers/block/xen-blkback/common.h
> @@ -126,6 +126,8 @@ struct blkif_x86_64_response {
> =A0 =A0 =A0 =A0int16_t =A0 =A0 =A0 =A0 status; =A0 =A0 =A0 =A0 =A0/* BLKI=
F_RSP_??? =A0 =A0 =A0 */
> =A0};
>
> +extern int xen_blkif_max_ring_order;
> +
> =A0DEFINE_RING_TYPES(blkif_common, struct blkif_common_request,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct blkif_common_response);
> =A0DEFINE_RING_TYPES(blkif_x86_32, struct blkif_x86_32_request,
> diff --git a/drivers/block/xen-blkback/xenbus.c b/drivers/block/xen-blkba=
ck/xenbus.c
> index 24a2fb5..7a9d71d 100644
> --- a/drivers/block/xen-blkback/xenbus.c
> +++ b/drivers/block/xen-blkback/xenbus.c
> @@ -122,8 +122,8 @@ static struct xen_blkif *xen_blkif_alloc(domid_t domi=
d)
> =A0 =A0 =A0 =A0return blkif;
> =A0}
>
> -static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_p=
age,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int evtchn)
> +static int xen_blkif_map(struct xen_blkif *blkif, int ring_ref[],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int ring_order,=
 unsigned int evtchn)
> =A0{
> =A0 =A0 =A0 =A0int err;
>
> @@ -131,7 +131,8 @@ static int xen_blkif_map(struct xen_blkif *blkif, uns=
igned long shared_page,
> =A0 =A0 =A0 =A0if (blkif->irq)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 err =3D xenbus_map_ring_valloc(blkif->be->dev, shared_page,=
 &blkif->blk_ring);
> + =A0 =A0 =A0 err =3D xenbus_map_ring_valloc(blkif->be->dev, ring_ref, 1 =
<< ring_order,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
&blkif->blk_ring);
> =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
>
> @@ -140,21 +141,24 @@ static int xen_blkif_map(struct xen_blkif *blkif, u=
nsigned long shared_page,
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct blkif_sring *sring;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sring =3D (struct blkif_sring *)blkif->blk=
_ring;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BACK_RING_INIT(&blkif->blk_rings.native, sr=
ing, PAGE_SIZE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BACK_RING_INIT(&blkif->blk_rings.native, sr=
ing,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PAGE_SIZE <<=
 ring_order);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0case BLKIF_PROTOCOL_X86_32:
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct blkif_x86_32_sring *sring_x86_32;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sring_x86_32 =3D (struct blkif_x86_32_srin=
g *)blkif->blk_ring;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BACK_RING_INIT(&blkif->blk_rings.x86_32, sr=
ing_x86_32, PAGE_SIZE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BACK_RING_INIT(&blkif->blk_rings.x86_32, sr=
ing_x86_32,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PAGE_SIZE <<=
 ring_order);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0case BLKIF_PROTOCOL_X86_64:
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct blkif_x86_64_sring *sring_x86_64;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sring_x86_64 =3D (struct blkif_x86_64_srin=
g *)blkif->blk_ring;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BACK_RING_INIT(&blkif->blk_rings.x86_64, sr=
ing_x86_64, PAGE_SIZE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BACK_RING_INIT(&blkif->blk_rings.x86_64, sr=
ing_x86_64,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PAGE_SIZE <<=
 ring_order);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0default:
> @@ -497,6 +501,11 @@ static int xen_blkbk_probe(struct xenbus_device *dev,
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fail;
>
> + =A0 =A0 =A0 err =3D xenbus_printf(XBT_NIL, dev->nodename, "max-ring-pag=
e-order",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%u", xen_blkif_max=
_ring_order);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
> +
> =A0 =A0 =A0 =A0err =3D xenbus_switch_state(dev, XenbusStateInitWait);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fail;
> @@ -744,22 +753,80 @@ again:
> =A0static int connect_ring(struct backend_info *be)
> =A0{
> =A0 =A0 =A0 =A0struct xenbus_device *dev =3D be->dev;
> - =A0 =A0 =A0 unsigned long ring_ref;
> + =A0 =A0 =A0 int ring_ref[XENBUS_MAX_RING_PAGES];
> + =A0 =A0 =A0 unsigned int ring_order;
> =A0 =A0 =A0 =A0unsigned int evtchn;
> =A0 =A0 =A0 =A0char protocol[64] =3D "";
> =A0 =A0 =A0 =A0int err;
>
> =A0 =A0 =A0 =A0DPRINTK("%s", dev->otherend);
>
> - =A0 =A0 =A0 err =3D xenbus_gather(XBT_NIL, dev->otherend, "ring-ref", "=
%lu",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &ring_ref, "event-c=
hannel", "%u", &evtchn, NULL);
> - =A0 =A0 =A0 if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"reading=
 %s/ring-ref and event-channel",
> + =A0 =A0 =A0 err =3D xenbus_scanf(XBT_NIL, dev->otherend, "event-channel=
", "%u",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&evtchn);
> + =A0 =A0 =A0 if (err !=3D 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err, "reading %s/even=
t-channel",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->othe=
rend);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 printk(KERN_INFO "blkback: event-channel %u\n", evtchn);
> +
> + =A0 =A0 =A0 err =3D xenbus_scanf(XBT_NIL, dev->otherend, "ring-page-ord=
er", "%u",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&ring_order);
> + =A0 =A0 =A0 if (err !=3D 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DPRINTK("%s: using single page handshake", =
dev->otherend);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ring_order =3D 0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D xenbus_scanf(XBT_NIL, dev->otherend=
, "ring-ref",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"%d"=
, &ring_ref[0]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err !=3D 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err, =
"reading %s/ring-ref",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0dev->otherend);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "blkback: ring-ref %d\n", =
ring_ref[0]);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int i;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ring_order > xen_blkif_max_ring_order) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0"%s/ring-page-order too big",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0dev->otherend);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < (1u << ring_order); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char ring_ref_name[10];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(ring_ref_name, siz=
eof(ring_ref_name),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"ring-re=
f%u", i);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D xenbus_scanf(XBT_NI=
L, dev->otherend,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0ring_ref_name, "%d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0&ring_ref[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err !=3D 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EI=
NVAL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_=
fatal(dev, err,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0"reading %s/%s",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0dev->otherend,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0ring_ref_name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "blkback: =
ring-ref%u %d\n", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ring_ref[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0be->blkif->blk_protocol =3D BLKIF_PROTOCOL_NATIVE;
> =A0 =A0 =A0 =A0err =3D xenbus_gather(XBT_NIL, dev->otherend, "protocol",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"%63s", protocol, =
NULL);
> @@ -775,14 +842,11 @@ static int connect_ring(struct backend_info *be)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xenbus_dev_fatal(dev, err, "unknown fe pro=
tocol %s", protocol);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 pr_info(DRV_PFX "ring-ref %ld, event-channel %d, protocol %=
d (%s)\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ring_ref, evtchn, be->blkif->blk_protocol, =
protocol);
>
> =A0 =A0 =A0 =A0/* Map the shared frame, irq etc. */
> - =A0 =A0 =A0 err =3D xen_blkif_map(be->blkif, ring_ref, evtchn);
> + =A0 =A0 =A0 err =3D xen_blkif_map(be->blkif, ring_ref, ring_order, evtc=
hn);
> =A0 =A0 =A0 =A0if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err, "mapping ring-re=
f %lu port %u",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ring_ref=
, evtchn);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err, "mapping ring-re=
fs and evtchn");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0}
>
> diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
> index 2f22874..485813a 100644
> --- a/drivers/block/xen-blkfront.c
> +++ b/drivers/block/xen-blkfront.c
> @@ -57,6 +57,10 @@
>
> =A0#include <asm/xen/hypervisor.h>
>
> +static int xen_blkif_ring_order;
> +module_param_named(reqs, xen_blkif_ring_order, int, 0);
> +MODULE_PARM_DESC(reqs, "log2 of requested ring size, in pages.");
> +
> =A0enum blkif_state {
> =A0 =A0 =A0 =A0BLKIF_STATE_DISCONNECTED,
> =A0 =A0 =A0 =A0BLKIF_STATE_CONNECTED,
> @@ -72,7 +76,8 @@ struct blk_shadow {
> =A0static DEFINE_MUTEX(blkfront_mutex);
> =A0static const struct block_device_operations xlvbd_block_fops;
>
> -#define BLK_RING_SIZE __CONST_RING_SIZE(blkif, PAGE_SIZE)
> +#define BLK_RING_SIZE(_order) =A0__CONST_RING_SIZE(blkif, PAGE_SIZE << (=
_order))
> +#define BLK_MAX_RING_SIZE =A0 =A0 =A0BLK_RING_SIZE(XENBUS_MAX_RING_ORDER)
>
> =A0/*
> =A0* We have one of these per vbd, whether ide, scsi or 'other'. =A0They
> @@ -87,14 +92,15 @@ struct blkfront_info
> =A0 =A0 =A0 =A0int vdevice;
> =A0 =A0 =A0 =A0blkif_vdev_t handle;
> =A0 =A0 =A0 =A0enum blkif_state connected;
> - =A0 =A0 =A0 int ring_ref;
> + =A0 =A0 =A0 int ring_ref[XENBUS_MAX_RING_PAGES];
> + =A0 =A0 =A0 int ring_order;
> =A0 =A0 =A0 =A0struct blkif_front_ring ring;
> =A0 =A0 =A0 =A0struct scatterlist sg[BLKIF_MAX_SEGMENTS_PER_REQUEST];
> =A0 =A0 =A0 =A0unsigned int evtchn, irq;
> =A0 =A0 =A0 =A0struct request_queue *rq;
> =A0 =A0 =A0 =A0struct work_struct work;
> =A0 =A0 =A0 =A0struct gnttab_free_callback callback;
> - =A0 =A0 =A0 struct blk_shadow shadow[BLK_RING_SIZE];
> + =A0 =A0 =A0 struct blk_shadow shadow[BLK_MAX_RING_SIZE];
> =A0 =A0 =A0 =A0unsigned long shadow_free;
> =A0 =A0 =A0 =A0unsigned int feature_flush;
> =A0 =A0 =A0 =A0unsigned int flush_op;
> @@ -111,9 +117,7 @@ static unsigned int nr_minors;
> =A0static unsigned long *minors;
> =A0static DEFINE_SPINLOCK(minor_lock);
>
> -#define MAXIMUM_OUTSTANDING_BLOCK_REQS \
> - =A0 =A0 =A0 (BLKIF_MAX_SEGMENTS_PER_REQUEST * BLK_RING_SIZE)
> -#define GRANT_INVALID_REF =A0 =A0 =A00
> +#define GRANT_INVALID_REF =A0 =A0 =A00
>
> =A0#define PARTS_PER_DISK =A0 =A0 =A0 =A0 16
> =A0#define PARTS_PER_EXT_DISK =A0 =A0 =A0256
> @@ -135,7 +139,7 @@ static DEFINE_SPINLOCK(minor_lock);
> =A0static int get_id_from_freelist(struct blkfront_info *info)
> =A0{
> =A0 =A0 =A0 =A0unsigned long free =3D info->shadow_free;
> - =A0 =A0 =A0 BUG_ON(free >=3D BLK_RING_SIZE);
> + =A0 =A0 =A0 BUG_ON(free >=3D BLK_MAX_RING_SIZE);
> =A0 =A0 =A0 =A0info->shadow_free =3D info->shadow[free].req.u.rw.id;
> =A0 =A0 =A0 =A0info->shadow[free].req.u.rw.id =3D 0x0fffffee; /* debug */
> =A0 =A0 =A0 =A0return free;
> @@ -683,6 +687,8 @@ static void blkif_restart_queue(struct work_struct *w=
ork)
>
> =A0static void blkif_free(struct blkfront_info *info, int suspend)
> =A0{
> + =A0 =A0 =A0 int i;
> +
> =A0 =A0 =A0 =A0/* Prevent new requests being issued until we fix things u=
p. */
> =A0 =A0 =A0 =A0spin_lock_irq(&blkif_io_lock);
> =A0 =A0 =A0 =A0info->connected =3D suspend ?
> @@ -698,16 +704,19 @@ static void blkif_free(struct blkfront_info *info, =
int suspend)
> =A0 =A0 =A0 =A0flush_work_sync(&info->work);
>
> =A0 =A0 =A0 =A0/* Free resources associated with old device channel. */
> - =A0 =A0 =A0 if (info->ring_ref !=3D GRANT_INVALID_REF) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 gnttab_end_foreign_access(info->ring_ref, 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 (unsigned long)info->ring.sring);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->ring_ref =3D GRANT_INVALID_REF;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->ring.sring =3D NULL;
> + =A0 =A0 =A0 for (i =3D 0; i < (1 << info->ring_order); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (info->ring_ref[i] !=3D GRANT_INVALID_RE=
F) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gnttab_end_foreign_access(i=
nfo->ring_ref[i], 0, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->ring_ref[i] =3D GRANT=
_INVALID_REF;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 free_pages((unsigned long)info->ring.sring, info->ring_orde=
r);
> + =A0 =A0 =A0 info->ring.sring =3D NULL;
> +
> =A0 =A0 =A0 =A0if (info->irq)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unbind_from_irqhandler(info->irq, info);
> =A0 =A0 =A0 =A0info->evtchn =3D info->irq =3D 0;
> -
> =A0}
>
> =A0static void blkif_completion(struct blk_shadow *s)
> @@ -828,25 +837,24 @@ static int setup_blkring(struct xenbus_device *dev,
> =A0 =A0 =A0 =A0struct blkif_sring *sring;
> =A0 =A0 =A0 =A0int err;
>
> - =A0 =A0 =A0 info->ring_ref =3D GRANT_INVALID_REF;
> -
> - =A0 =A0 =A0 sring =3D (struct blkif_sring *)__get_free_page(GFP_NOIO | =
__GFP_HIGH);
> + =A0 =A0 =A0 sring =3D (struct blkif_sring *)__get_free_pages(GFP_NOIO |=
 __GFP_HIGH,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->ring_order);
> =A0 =A0 =A0 =A0if (!sring) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xenbus_dev_fatal(dev, -ENOMEM, "allocating=
 shared ring");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0SHARED_RING_INIT(sring);
> - =A0 =A0 =A0 FRONT_RING_INIT(&info->ring, sring, PAGE_SIZE);
> + =A0 =A0 =A0 FRONT_RING_INIT(&info->ring, sring, PAGE_SIZE << info->ring=
_order);
>
> =A0 =A0 =A0 =A0sg_init_table(info->sg, BLKIF_MAX_SEGMENTS_PER_REQUEST);
>
> - =A0 =A0 =A0 err =3D xenbus_grant_ring(dev, virt_to_mfn(info->ring.sring=
));
> + =A0 =A0 =A0 err =3D xenbus_grant_ring(dev, info->ring.sring, 1 << info-=
>ring_order,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->ring_=
ref);
> =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page((unsigned long)sring);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages((unsigned long)sring, info->ring=
_order);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->ring.sring =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fail;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 info->ring_ref =3D err;
>
> =A0 =A0 =A0 =A0err =3D xenbus_alloc_evtchn(dev, &info->evtchn);
> =A0 =A0 =A0 =A0if (err)
> @@ -875,8 +883,27 @@ static int talk_to_blkback(struct xenbus_device *dev,
> =A0{
> =A0 =A0 =A0 =A0const char *message =3D NULL;
> =A0 =A0 =A0 =A0struct xenbus_transaction xbt;
> + =A0 =A0 =A0 unsigned int ring_order;
> + =A0 =A0 =A0 int legacy_backend;
> + =A0 =A0 =A0 int i;
> =A0 =A0 =A0 =A0int err;
>
> + =A0 =A0 =A0 for (i =3D 0; i < (1 << info->ring_order); i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->ring_ref[i] =3D GRANT_INVALID_REF;
> +
> + =A0 =A0 =A0 err =3D xenbus_scanf(XBT_NIL, dev->otherend, "max-ring-page=
-order", "%u",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&ring_order);
> +
> + =A0 =A0 =A0 legacy_backend =3D !(err =3D=3D 1);
> +
> + =A0 =A0 =A0 if (legacy_backend) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->ring_order =3D 0;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->ring_order =3D (ring_order <=3D xen_b=
lkif_ring_order) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ring=
_order :
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xen_=
blkif_ring_order;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* Create shared ring, alloc event channel. */
> =A0 =A0 =A0 =A0err =3D setup_blkring(dev, info);
> =A0 =A0 =A0 =A0if (err)
> @@ -889,12 +916,35 @@ again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto destroy_blkring;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 err =3D xenbus_printf(xbt, dev->nodename,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "ring-ref", "%u", i=
nfo->ring_ref);
> - =A0 =A0 =A0 if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 message =3D "writing ring-ref";
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto abort_transaction;
> + =A0 =A0 =A0 if (legacy_backend) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D xenbus_printf(xbt, dev->nodename,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "ri=
ng-ref", "%d", info->ring_ref[0]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 message =3D "writing ring-r=
ef";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto abort_transaction;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < (1 << info->ring_order); =
i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char key[sizeof("ring-ref")=
 + 2];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(key, "ring-ref%d", =
i);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D xenbus_printf(xbt, =
dev->nodename,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 key, "%d", info->ring_ref[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 message =3D=
 "writing ring-ref";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto abort_=
transaction;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D xenbus_printf(xbt, dev->nodename,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "ri=
ng-page-order", "%u", info->ring_order);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 message =3D "writing ring-o=
rder";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto abort_transaction;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
> +
> =A0 =A0 =A0 =A0err =3D xenbus_printf(xbt, dev->nodename,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"event-channel", "=
%u", info->evtchn);
> =A0 =A0 =A0 =A0if (err) {
> @@ -996,21 +1046,14 @@ static int blkfront_probe(struct xenbus_device *de=
v,
> =A0 =A0 =A0 =A0info->connected =3D BLKIF_STATE_DISCONNECTED;
> =A0 =A0 =A0 =A0INIT_WORK(&info->work, blkif_restart_queue);
>
> - =A0 =A0 =A0 for (i =3D 0; i < BLK_RING_SIZE; i++)
> + =A0 =A0 =A0 for (i =3D 0; i < BLK_MAX_RING_SIZE; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->shadow[i].req.u.rw.id =3D i+1;
> - =A0 =A0 =A0 info->shadow[BLK_RING_SIZE-1].req.u.rw.id =3D 0x0fffffff;
> + =A0 =A0 =A0 info->shadow[BLK_MAX_RING_SIZE-1].req.u.rw.id =3D 0x0ffffff=
f;
>
> =A0 =A0 =A0 =A0/* Front end dir is a number, which is used as the id. */
> =A0 =A0 =A0 =A0info->handle =3D simple_strtoul(strrchr(dev->nodename, '/'=
)+1, NULL, 0);
> =A0 =A0 =A0 =A0dev_set_drvdata(&dev->dev, info);
>
> - =A0 =A0 =A0 err =3D talk_to_blkback(dev, info);
> - =A0 =A0 =A0 if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(info);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_set_drvdata(&dev->dev, NULL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -1031,13 +1074,13 @@ static int blkif_recover(struct blkfront_info *in=
fo)
>
> =A0 =A0 =A0 =A0/* Stage 2: Set up free list. */
> =A0 =A0 =A0 =A0memset(&info->shadow, 0, sizeof(info->shadow));
> - =A0 =A0 =A0 for (i =3D 0; i < BLK_RING_SIZE; i++)
> + =A0 =A0 =A0 for (i =3D 0; i < BLK_MAX_RING_SIZE; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->shadow[i].req.u.rw.id =3D i+1;
> =A0 =A0 =A0 =A0info->shadow_free =3D info->ring.req_prod_pvt;
> - =A0 =A0 =A0 info->shadow[BLK_RING_SIZE-1].req.u.rw.id =3D 0x0fffffff;
> + =A0 =A0 =A0 info->shadow[BLK_MAX_RING_SIZE-1].req.u.rw.id =3D 0x0ffffff=
f;
>
> =A0 =A0 =A0 =A0/* Stage 3: Find pending requests and requeue them. */
> - =A0 =A0 =A0 for (i =3D 0; i < BLK_RING_SIZE; i++) {
> + =A0 =A0 =A0 for (i =3D 0; i < BLK_RING_SIZE(info->ring_order); i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Not in use? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!copy[i].request)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> @@ -1299,7 +1342,6 @@ static void blkback_changed(struct xenbus_device *d=
ev,
>
> =A0 =A0 =A0 =A0switch (backend_state) {
> =A0 =A0 =A0 =A0case XenbusStateInitialising:
> - =A0 =A0 =A0 case XenbusStateInitWait:
> =A0 =A0 =A0 =A0case XenbusStateInitialised:
> =A0 =A0 =A0 =A0case XenbusStateReconfiguring:
> =A0 =A0 =A0 =A0case XenbusStateReconfigured:
> @@ -1307,6 +1349,10 @@ static void blkback_changed(struct xenbus_device *=
dev,
> =A0 =A0 =A0 =A0case XenbusStateClosed:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> + =A0 =A0 =A0 case XenbusStateInitWait:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 talk_to_blkback(dev, info);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> =A0 =A0 =A0 =A0case XenbusStateConnected:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blkfront_connect(info);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/c=
ommon.h
> index 94b79c3..f93b59a 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -130,8 +130,8 @@ int xen_netbk_must_stop_queue(struct xenvif *vif);
> =A0/* (Un)Map communication rings. */
> =A0void xen_netbk_unmap_frontend_rings(struct xenvif *vif);
> =A0int xen_netbk_map_frontend_rings(struct xenvif *vif,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0grant_re=
f_t tx_ring_ref,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0grant_re=
f_t rx_ring_ref);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int tx_r=
ing_ref,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int rx_r=
ing_ref);
>
> =A0/* (De)Register a xenvif with the netback backend. */
> =A0void xen_netbk_add_xenvif(struct xenvif *vif);
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/=
netback.c
> index 59effac..0b014cf 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1594,8 +1594,8 @@ void xen_netbk_unmap_frontend_rings(struct xenvif *=
vif)
> =A0}
>
> =A0int xen_netbk_map_frontend_rings(struct xenvif *vif,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0grant_re=
f_t tx_ring_ref,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0grant_re=
f_t rx_ring_ref)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int tx_r=
ing_ref,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int rx_r=
ing_ref)
> =A0{
> =A0 =A0 =A0 =A0void *addr;
> =A0 =A0 =A0 =A0struct xen_netif_tx_sring *txs;
> @@ -1604,7 +1604,7 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
> =A0 =A0 =A0 =A0int err =3D -ENOMEM;
>
> =A0 =A0 =A0 =A0err =3D xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif=
),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
tx_ring_ref, &addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
&tx_ring_ref, 1, &addr);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err;
>
> @@ -1612,7 +1612,7 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
> =A0 =A0 =A0 =A0BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
>
> =A0 =A0 =A0 =A0err =3D xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif=
),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
rx_ring_ref, &addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
&rx_ring_ref, 1, &addr);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err;
>
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 698b905..521a595 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1496,13 +1496,12 @@ static int setup_netfront(struct xenbus_device *d=
ev, struct netfront_info *info)
> =A0 =A0 =A0 =A0SHARED_RING_INIT(txs);
> =A0 =A0 =A0 =A0FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
>
> - =A0 =A0 =A0 err =3D xenbus_grant_ring(dev, virt_to_mfn(txs));
> + =A0 =A0 =A0 err =3D xenbus_grant_ring(dev, txs, 1, &info->tx_ring_ref);
> =A0 =A0 =A0 =A0if (err < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_page((unsigned long)txs);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fail;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 info->tx_ring_ref =3D err;
> =A0 =A0 =A0 =A0rxs =3D (struct xen_netif_rx_sring *)get_zeroed_page(GFP_N=
OIO | __GFP_HIGH);
> =A0 =A0 =A0 =A0if (!rxs) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> @@ -1512,12 +1511,11 @@ static int setup_netfront(struct xenbus_device *d=
ev, struct netfront_info *info)
> =A0 =A0 =A0 =A0SHARED_RING_INIT(rxs);
> =A0 =A0 =A0 =A0FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);
>
> - =A0 =A0 =A0 err =3D xenbus_grant_ring(dev, virt_to_mfn(rxs));
> + =A0 =A0 =A0 err =3D xenbus_grant_ring(dev, rxs, 1, &info->rx_ring_ref);
> =A0 =A0 =A0 =A0if (err < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_page((unsigned long)rxs);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fail;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 info->rx_ring_ref =3D err;
>
> =A0 =A0 =A0 =A0err =3D xenbus_alloc_evtchn(dev, &info->evtchn);
> =A0 =A0 =A0 =A0if (err)
> diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
> index 1620088..95109d8 100644
> --- a/drivers/pci/xen-pcifront.c
> +++ b/drivers/pci/xen-pcifront.c
> @@ -768,12 +768,10 @@ static int pcifront_publish_info(struct pcifront_de=
vice *pdev)
> =A0 =A0 =A0 =A0int err =3D 0;
> =A0 =A0 =A0 =A0struct xenbus_transaction trans;
>
> - =A0 =A0 =A0 err =3D xenbus_grant_ring(pdev->xdev, virt_to_mfn(pdev->sh_=
info));
> + =A0 =A0 =A0 err =3D xenbus_grant_ring(pdev->xdev, pdev->sh_info, 1, &pd=
ev->gnt_ref);
> =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> - =A0 =A0 =A0 pdev->gnt_ref =3D err;
> -
> =A0 =A0 =A0 =A0err =3D xenbus_alloc_evtchn(pdev->xdev, &pdev->evtchn);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/x=
enbus.c
> index 64b11f9..e0834cd 100644
> --- a/drivers/xen/xen-pciback/xenbus.c
> +++ b/drivers/xen/xen-pciback/xenbus.c
> @@ -108,7 +108,7 @@ static int xen_pcibk_do_attach(struct xen_pcibk_devic=
e *pdev, int gnt_ref,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Attaching to frontend resources - gnt_ref=
=3D%d evtchn=3D%d\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gnt_ref, remote_evtchn);
>
> - =A0 =A0 =A0 err =3D xenbus_map_ring_valloc(pdev->xdev, gnt_ref, &vaddr);
> + =A0 =A0 =A0 err =3D xenbus_map_ring_valloc(pdev->xdev, &gnt_ref, 1, &va=
ddr);
> =A0 =A0 =A0 =A0if (err < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xenbus_dev_fatal(pdev->xdev, err,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Error map=
ping other domain page in ours.");
> diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenb=
us_client.c
> index 566d2ad..3a14524 100644
> --- a/drivers/xen/xenbus/xenbus_client.c
> +++ b/drivers/xen/xenbus/xenbus_client.c
> @@ -53,14 +53,16 @@ struct xenbus_map_node {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vm_struct *area; /* PV */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page; =A0 =A0 /* HVM */
> =A0 =A0 =A0 =A0};
> - =A0 =A0 =A0 grant_handle_t handle;
> + =A0 =A0 =A0 grant_handle_t handle[XENBUS_MAX_RING_PAGES];
> + =A0 =A0 =A0 unsigned int =A0 nr_handles;
> =A0};
>
> =A0static DEFINE_SPINLOCK(xenbus_valloc_lock);
> =A0static LIST_HEAD(xenbus_valloc_pages);
>
> =A0struct xenbus_ring_ops {
> - =A0 =A0 =A0 int (*map)(struct xenbus_device *dev, int gnt, void **vaddr=
);
> + =A0 =A0 =A0 int (*map)(struct xenbus_device *dev, int gnt[], int nr_gnt=
s,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void **vaddr);
> =A0 =A0 =A0 =A0int (*unmap)(struct xenbus_device *dev, void *vaddr);
> =A0};
>
> @@ -356,17 +358,38 @@ static void xenbus_switch_fatal(struct xenbus_devic=
e *dev, int depth, int err,
> =A0/**
> =A0* xenbus_grant_ring
> =A0* @dev: xenbus device
> - * @ring_mfn: mfn of ring to grant
> -
> - * Grant access to the given @ring_mfn to the peer of the given device. =
=A0Return
> - * 0 on success, or -errno on error. =A0On error, the device will switch=
 to
> - * XenbusStateClosing, and the error will be saved in the store.
> + * @vaddr: starting virtual address of the ring
> + * @nr_pages: number of page to be granted
> + * @grefs: grant reference array to be filled in
> + * Grant access to the given @vaddr to the peer of the given device.
> + * Then fill in @grefs with grant references. =A0Return 0 on success, or
> + * -errno on error. =A0On error, the device will switch to
> + * XenbusStateClosing, and the first error will be saved in the store.
> =A0*/
> -int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn)
> +int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nr_pages, int grefs[])
> =A0{
> - =A0 =A0 =A0 int err =3D gnttab_grant_foreign_access(dev->otherend_id, r=
ing_mfn, 0);
> - =A0 =A0 =A0 if (err < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err, "granting access=
 to ring page");
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < nr_pages; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long addr =3D (unsigned long)vaddr=
 +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (PAGE_SIZE * i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D gnttab_grant_foreign_access(dev->ot=
herend_id,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 virt_to_mfn(addr), 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0"granting access to ring page");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 grefs[i] =3D err;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +
> +fail:
> + =A0 =A0 =A0 for ( ; i >=3D 0; i--)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 gnttab_end_foreign_access_ref(grefs[i], 0);
> =A0 =A0 =A0 =A0return err;
> =A0}
> =A0EXPORT_SYMBOL_GPL(xenbus_grant_ring);
> @@ -447,7 +470,8 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
> =A0/**
> =A0* xenbus_map_ring_valloc
> =A0* @dev: xenbus device
> - * @gnt_ref: grant reference
> + * @gnt_ref: grant reference array
> + * @nr_grefs: number of grant reference
> =A0* @vaddr: pointer to address to be filled out by mapping
> =A0*
> =A0* Based on Rusty Russell's skeleton driver's map_page.
> @@ -458,23 +482,28 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
> =A0* or -ENOMEM on error. If an error is returned, device will switch to
> =A0* XenbusStateClosing and the error message will be saved in XenStore.
> =A0*/
> -int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref, void =
**vaddr)
> +int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref[],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nr_grefs, void *=
*vaddr)
> =A0{
> - =A0 =A0 =A0 return ring_ops->map(dev, gnt_ref, vaddr);
> + =A0 =A0 =A0 return ring_ops->map(dev, gnt_ref, nr_grefs, vaddr);
> =A0}
> =A0EXPORT_SYMBOL_GPL(xenbus_map_ring_valloc);
>
> +static int __xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct xenbus_map_node *node);
> +
> =A0static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
int gnt_ref, void **vaddr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
int gnt_ref[], int nr_grefs, void **vaddr)
> =A0{
> - =A0 =A0 =A0 struct gnttab_map_grant_ref op =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D GNTMAP_host_map | GNTMAP_contain=
s_pte,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .ref =A0 =3D gnt_ref,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .dom =A0 =3D dev->otherend_id,
> - =A0 =A0 =A0 };
> + =A0 =A0 =A0 struct gnttab_map_grant_ref op[XENBUS_MAX_RING_PAGES];
> =A0 =A0 =A0 =A0struct xenbus_map_node *node;
> =A0 =A0 =A0 =A0struct vm_struct *area;
> - =A0 =A0 =A0 pte_t *pte;
> + =A0 =A0 =A0 pte_t *pte[XENBUS_MAX_RING_PAGES];
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 int err =3D 0;
> +
> + =A0 =A0 =A0 if (nr_grefs > XENBUS_MAX_RING_PAGES)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>
> =A0 =A0 =A0 =A0*vaddr =3D NULL;
>
> @@ -482,28 +511,44 @@ static int xenbus_map_ring_valloc_pv(struct xenbus_=
device *dev,
> =A0 =A0 =A0 =A0if (!node)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> - =A0 =A0 =A0 area =3D alloc_vm_area(PAGE_SIZE, &pte);
> + =A0 =A0 =A0 area =3D alloc_vm_area(PAGE_SIZE * nr_grefs, pte);
> =A0 =A0 =A0 =A0if (!area) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(node);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 op.host_addr =3D arbitrary_virt_to_machine(pte).maddr;
> + =A0 =A0 =A0 for (i =3D 0; i < nr_grefs; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 op[i].flags =3D GNTMAP_host_map | GNTMAP_co=
ntains_pte,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 op[i].ref =A0 =3D gnt_ref[i],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 op[i].dom =A0 =3D dev->otherend_id,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 op[i].host_addr =3D arbitrary_virt_to_machi=
ne(pte[i]).maddr;
> + =A0 =A0 =A0 };
>
> =A0 =A0 =A0 =A0if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op,=
 1))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>
> - =A0 =A0 =A0 if (op.status !=3D GNTST_okay) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_vm_area(area);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(node);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, op.status,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"mapping=
 in shared page %d from domain %d",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gnt_ref,=
 dev->otherend_id);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return op.status;
> + =A0 =A0 =A0 node->nr_handles =3D nr_grefs;
> + =A0 =A0 =A0 node->area =3D area;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < nr_grefs; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (op[i].status !=3D GNTST_okay) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D op[i].status;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node->handle[i] =3D INVALID=
_GRANT_HANDLE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 node->handle[i] =3D op[i].handle;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 node->handle =3D op.handle;
> - =A0 =A0 =A0 node->area =3D area;
> + =A0 =A0 =A0 if (err !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < nr_grefs; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, op[i]=
.status,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "mapping in=
 shared page %d from domain %d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gnt_ref[i],=
 dev->otherend_id);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__xenbus_unmap_ring_vfree_pv(dev, node);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0spin_lock(&xenbus_valloc_lock);
> =A0 =A0 =A0 =A0list_add(&node->next, &xenbus_valloc_pages);
> @@ -514,25 +559,29 @@ static int xenbus_map_ring_valloc_pv(struct xenbus_=
device *dev,
> =A0}
>
> =A0static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 int gnt_ref, void **vaddr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 int gnt_ref[], int nr_grefs, void **vaddr)
> =A0{
> =A0 =A0 =A0 =A0struct xenbus_map_node *node;
> =A0 =A0 =A0 =A0int err;
> =A0 =A0 =A0 =A0void *addr;
>
> + =A0 =A0 =A0 if (nr_grefs > XENBUS_MAX_RING_PAGES)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> =A0 =A0 =A0 =A0*vaddr =3D NULL;
>
> =A0 =A0 =A0 =A0node =3D kzalloc(sizeof(*node), GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!node)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> - =A0 =A0 =A0 err =3D alloc_xenballooned_pages(1, &node->page, false /* l=
owmem */);
> + =A0 =A0 =A0 err =3D alloc_xenballooned_pages(nr_grefs, &node->page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0false /* lowmem */);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_err;
>
> =A0 =A0 =A0 =A0addr =3D pfn_to_kaddr(page_to_pfn(node->page));
>
> - =A0 =A0 =A0 err =3D xenbus_map_ring(dev, gnt_ref, &node->handle, addr);
> + =A0 =A0 =A0 err =3D xenbus_map_ring(dev, gnt_ref, nr_grefs, node->handl=
e, addr);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_err;
>
> @@ -544,7 +593,7 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus_d=
evice *dev,
> =A0 =A0 =A0 =A0return 0;
>
> =A0out_err:
> - =A0 =A0 =A0 free_xenballooned_pages(1, &node->page);
> + =A0 =A0 =A0 free_xenballooned_pages(nr_grefs, &node->page);
> =A0 =A0 =A0 =A0kfree(node);
> =A0 =A0 =A0 =A0return err;
> =A0}
> @@ -553,36 +602,51 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus=
_device *dev,
> =A0/**
> =A0* xenbus_map_ring
> =A0* @dev: xenbus device
> - * @gnt_ref: grant reference
> - * @handle: pointer to grant handle to be filled
> + * @gnt_ref: grant reference array
> + * @nr_grefs: number of grant references
> + * @handle: pointer to grant handle array to be filled, mind the size
> =A0* @vaddr: address to be mapped to
> =A0*
> - * Map a page of memory into this domain from another domain's grant tab=
le.
> + * Map pages of memory into this domain from another domain's grant tabl=
e.
> =A0* xenbus_map_ring does not allocate the virtual address space (you mus=
t do
> - * this yourself!). It only maps in the page to the specified address.
> + * this yourself!). It only maps in the pages to the specified address.
> =A0* Returns 0 on success, and GNTST_* (see xen/include/interface/grant_t=
able.h)
> =A0* or -ENOMEM on error. If an error is returned, device will switch to
> - * XenbusStateClosing and the error message will be saved in XenStore.
> + * XenbusStateClosing and the last error message will be saved in XenSto=
re.
> =A0*/
> -int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grant_handle_t *handle, void *vaddr)
> +int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref[], int nr_gre=
fs,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grant_handle_t handle[], void *vadd=
r)
> =A0{
> - =A0 =A0 =A0 struct gnttab_map_grant_ref op;
> -
> - =A0 =A0 =A0 gnttab_set_map_op(&op, (phys_addr_t)vaddr, GNTMAP_host_map,=
 gnt_ref,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->otherend_id);
> + =A0 =A0 =A0 struct gnttab_map_grant_ref op[XENBUS_MAX_RING_PAGES];
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 int err =3D GNTST_okay; =A0 /* 0 */
> +
> + =A0 =A0 =A0 for (i =3D 0; i < nr_grefs; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long addr =3D (unsigned long)vaddr=
 +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (PAGE_SIZE * i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 gnttab_set_map_op(&op[i], (phys_addr_t)addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GNTMAP_=
host_map, gnt_ref[i],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->ot=
herend_id);
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, =
1))
> + =A0 =A0 =A0 if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, op, n=
r_grefs))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>
> - =A0 =A0 =A0 if (op.status !=3D GNTST_okay) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, op.status,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"mapping=
 in shared page %d from domain %d",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gnt_ref,=
 dev->otherend_id);
> - =A0 =A0 =A0 } else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *handle =3D op.handle;
> + =A0 =A0 =A0 for (i =3D 0; i < nr_grefs; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (op[i].status !=3D GNTST_okay) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D op[i].status;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_fatal(dev, err,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "mapping in=
 shared page %d from domain %d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gnt_ref[i],=
 dev->otherend_id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 handle[i] =3D INVALID_GRANT=
_HANDLE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 handle[i] =3D op[i].handle;
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 return op.status;
> + =A0 =A0 =A0 if (err !=3D GNTST_okay)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_unmap_ring(dev, handle, nr_grefs, va=
ddr);
> +
> + =A0 =A0 =A0 return err;
> =A0}
> =A0EXPORT_SYMBOL_GPL(xenbus_map_ring);
>
> @@ -605,13 +669,53 @@ int xenbus_unmap_ring_vfree(struct xenbus_device *d=
ev, void *vaddr)
> =A0}
> =A0EXPORT_SYMBOL_GPL(xenbus_unmap_ring_vfree);
>
> +static int __xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct xenbus_map_node *node)
> +{
> + =A0 =A0 =A0 struct gnttab_unmap_grant_ref op[XENBUS_MAX_RING_PAGES];
> + =A0 =A0 =A0 unsigned int level;
> + =A0 =A0 =A0 int i, j;
> + =A0 =A0 =A0 int err =3D GNTST_okay;
> +
> + =A0 =A0 =A0 j =3D 0;
> + =A0 =A0 =A0 for (i =3D 0; i < node->nr_handles; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long vaddr =3D (unsigned long)node=
->area->addr +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (PAGE_SIZE * i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (node->handle[i] !=3D INVALID_GRANT_HAND=
LE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&op[j], 0, sizeof(op=
[0]));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 op[j].host_addr =3D arbitra=
ry_virt_to_machine(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 lookup_address(vaddr, &level)).maddr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 op[j].handle =3D node->hand=
le[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 j++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node->handle[i] =3D INVALID=
_GRANT_HANDLE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, op,=
 j))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> +
> + =A0 =A0 =A0 node->nr_handles =3D 0;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < j; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (op[i].status !=3D GNTST_okay) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D op[i].status;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_error(dev, err,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "unmapping =
page %d at handle %d error %d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i, op[i].ha=
ndle, err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (err =3D=3D GNTST_okay)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_vm_area(node->area);
> +
> + =A0 =A0 =A0 kfree(node);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> =A0static int xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev, void =
*vaddr)
> =A0{
> =A0 =A0 =A0 =A0struct xenbus_map_node *node;
> - =A0 =A0 =A0 struct gnttab_unmap_grant_ref op =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .host_addr =3D (unsigned long)vaddr,
> - =A0 =A0 =A0 };
> - =A0 =A0 =A0 unsigned int level;
>
> =A0 =A0 =A0 =A0spin_lock(&xenbus_valloc_lock);
> =A0 =A0 =A0 =A0list_for_each_entry(node, &xenbus_valloc_pages, next) {
> @@ -626,33 +730,18 @@ static int xenbus_unmap_ring_vfree_pv(struct xenbus=
_device *dev, void *vaddr)
>
> =A0 =A0 =A0 =A0if (!node) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xenbus_dev_error(dev, -ENOENT,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"can't f=
ind mapped virtual address %p", vaddr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "can't find=
 mapped virtual address %p", vaddr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return GNTST_bad_virt_addr;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 op.handle =3D node->handle;
> - =A0 =A0 =A0 op.host_addr =3D arbitrary_virt_to_machine(
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 lookup_address((unsigned long)vaddr, &level=
)).maddr;
> -
> - =A0 =A0 =A0 if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op=
, 1))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> -
> - =A0 =A0 =A0 if (op.status =3D=3D GNTST_okay)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_vm_area(node->area);
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_error(dev, op.status,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"unmappi=
ng page at handle %d error %d",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0node->ha=
ndle, op.status);
> -
> - =A0 =A0 =A0 kfree(node);
> - =A0 =A0 =A0 return op.status;
> + =A0 =A0 =A0 return __xenbus_unmap_ring_vfree_pv(dev, node);
> =A0}
>
> =A0static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void=
 *vaddr)
> =A0{
> =A0 =A0 =A0 =A0int rv;
> =A0 =A0 =A0 =A0struct xenbus_map_node *node;
> - =A0 =A0 =A0 void *addr;
> + =A0 =A0 =A0 void *addr =3D NULL;
>
> =A0 =A0 =A0 =A0spin_lock(&xenbus_valloc_lock);
> =A0 =A0 =A0 =A0list_for_each_entry(node, &xenbus_valloc_pages, next) {
> @@ -668,14 +757,14 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbu=
s_device *dev, void *vaddr)
>
> =A0 =A0 =A0 =A0if (!node) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xenbus_dev_error(dev, -ENOENT,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"can't f=
ind mapped virtual address %p", vaddr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "can't find=
 mapped virtual address %p", vaddr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return GNTST_bad_virt_addr;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 rv =3D xenbus_unmap_ring(dev, node->handle, addr);
> + =A0 =A0 =A0 rv =3D xenbus_unmap_ring(dev, node->handle, node->nr_handle=
s, addr);
>
> =A0 =A0 =A0 =A0if (!rv)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_xenballooned_pages(1, &node->page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_xenballooned_pages(node->nr_handles, &=
node->page);
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN(1, "Leaking %p\n", vaddr);
>
> @@ -687,6 +776,7 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_=
device *dev, void *vaddr)
> =A0* xenbus_unmap_ring
> =A0* @dev: xenbus device
> =A0* @handle: grant handle
> + * @nr_handles: number of grant handle
> =A0* @vaddr: addr to unmap
> =A0*
> =A0* Unmap a page of memory in this domain that was imported from another=
 domain.
> @@ -694,21 +784,37 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbu=
s_device *dev, void *vaddr)
> =A0* (see xen/include/interface/grant_table.h).
> =A0*/
> =A0int xenbus_unmap_ring(struct xenbus_device *dev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grant_handle_t handle, void *va=
ddr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grant_handle_t handle[], in=
t nr_handles,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *vaddr)
> =A0{
> - =A0 =A0 =A0 struct gnttab_unmap_grant_ref op;
> -
> - =A0 =A0 =A0 gnttab_set_unmap_op(&op, (phys_addr_t)vaddr, GNTMAP_host_ma=
p, handle);
> + =A0 =A0 =A0 struct gnttab_unmap_grant_ref op[XENBUS_MAX_RING_PAGES];
> + =A0 =A0 =A0 int i, j;
> + =A0 =A0 =A0 int err =3D GNTST_okay;
> +
> + =A0 =A0 =A0 j =3D 0;
> + =A0 =A0 =A0 for (i =3D 0; i < nr_handles; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long addr =3D (unsigned long)vaddr=
 +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (PAGE_SIZE * i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (handle[i] !=3D INVALID_GRANT_HANDLE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gnttab_set_unmap_op(&op[j++=
], (phys_addr_t)addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 GNTMAP_host_map, handle[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 handle[i] =3D INVALID_GRANT=
_HANDLE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op=
, 1))
> + =A0 =A0 =A0 if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, op,=
 j))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>
> - =A0 =A0 =A0 if (op.status !=3D GNTST_okay)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_error(dev, op.status,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"unmappi=
ng page at handle %d error %d",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0handle, =
op.status);
> + =A0 =A0 =A0 for (i =3D 0; i < j; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (op[i].status !=3D GNTST_okay) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D op[i].status;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xenbus_dev_error(dev, err,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "unmapping =
page at handle %d error %d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 handle[i], =
err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 return op.status;
> + =A0 =A0 =A0 return err;
> =A0}
> =A0EXPORT_SYMBOL_GPL(xenbus_unmap_ring);
>
> diff --git a/drivers/xen/xenbus/xenbus_probe.c b/drivers/xen/xenbus/xenbu=
s_probe.c
> index 3864967..62b92d2 100644
> --- a/drivers/xen/xenbus/xenbus_probe.c
> +++ b/drivers/xen/xenbus/xenbus_probe.c
> @@ -718,6 +718,7 @@ static int __init xenstored_local_init(void)
> =A0 =A0 =A0 =A0return err;
> =A0}
>
> +extern void xenbus_ring_ops_init(void);
> =A0static int __init xenbus_init(void)
> =A0{
> =A0 =A0 =A0 =A0int err =3D 0;
> @@ -767,6 +768,8 @@ static int __init xenbus_init(void)
> =A0 =A0 =A0 =A0proc_mkdir("xen", NULL);
> =A0#endif
>
> + =A0 =A0 =A0 xenbus_ring_ops_init();
> +
> =A0out_error:
> =A0 =A0 =A0 =A0return err;
> =A0}
> diff --git a/include/xen/xenbus.h b/include/xen/xenbus.h
> index e8c599b..cdbd948 100644
> --- a/include/xen/xenbus.h
> +++ b/include/xen/xenbus.h
> @@ -195,15 +195,23 @@ int xenbus_watch_pathfmt(struct xenbus_device *dev,=
 struct xenbus_watch *watch,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *pathfmt, ...);
>
> =A0int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state n=
ew_state);
> -int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn);
> -int xenbus_map_ring_valloc(struct xenbus_device *dev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int gnt_ref, void **=
vaddr);
> -int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0grant_handle_t *hand=
le, void *vaddr);
> +
> +#define =A0 =A0 =A0 =A0XENBUS_MAX_RING_ORDER =A0 2
> +#define =A0 =A0 =A0 =A0XENBUS_MAX_RING_PAGES =A0 (1 << XENBUS_MAX_RING_O=
RDER)
> +
> +#define INVALID_GRANT_HANDLE =A0 =A0 =A0 =A0 =A0 (~0U)
> +
> +int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nr_pages, int grefs[]);
> +int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref[],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nr_grefs, void *=
*vaddr);
> +int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref[], int nr_gre=
fs,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grant_handle_t handle[], void *vadd=
r);
>
> =A0int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr);
> =A0int xenbus_unmap_ring(struct xenbus_device *dev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grant_handle_t handle, void *va=
ddr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grant_handle_t handle[], int nr=
_handles,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *vaddr);
>
> =A0int xenbus_alloc_evtchn(struct xenbus_device *dev, int *port);
> =A0int xenbus_bind_evtchn(struct xenbus_device *dev, int remote_port, int=
 *port);
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>

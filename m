From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH -net-next 1/4] firmware: convert e100
	driver to request_firmware()
Date: Tue, 30 Dec 2008 14:33:36 -0800
Message-ID: <9929d2390812301433pae01ea4g5bfdef6d4d4c7a9c@mail.gmail.com>
References: <1230626401.24796.22.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org,
	davem@redhat.com
To: "Jaswinder Singh Rajput" <jaswinder@infradead.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1230626401.24796.22.camel@jaswinder.satnam>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Dec 30, 2008 at 12:40 AM, Jaswinder Singh Rajput
<jaswinder@infradead.org> wrote:
> Thanks to David Woodhouse for help.
>
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> ---
>  drivers/net/e100.c                 |  289 ++++++++++++------------------------
>  firmware/Makefile                  |    2 +
>  firmware/WHENCE                    |   11 ++
>  firmware/e100/d101m_ucode.bin.ihex |   38 +++++
>  firmware/e100/d101s_ucode.bin.ihex |   38 +++++
>  firmware/e100/d102e_ucode.bin.ihex |   38 +++++
>  6 files changed, 219 insertions(+), 197 deletions(-)
>  create mode 100644 firmware/e100/d101m_ucode.bin.ihex
>  create mode 100644 firmware/e100/d101s_ucode.bin.ihex
>  create mode 100644 firmware/e100/d102e_ucode.bin.ihex
>
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 9f38b16..c2b3fce 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -161,6 +161,7 @@
>  #include <linux/skbuff.h>
>  #include <linux/ethtool.h>
>  #include <linux/string.h>
> +#include <linux/firmware.h>
>  #include <asm/unaligned.h>
>
>
> @@ -174,10 +175,17 @@
>  #define E100_WATCHDOG_PERIOD   (2 * HZ)
>  #define E100_NAPI_WEIGHT       16
>
> +#define FIRMWARE_D101M         "e100/d101m_ucode.bin"
> +#define FIRMWARE_D101S         "e100/d101s_ucode.bin"
> +#define FIRMWARE_D102E         "e100/d102e_ucode.bin"
> +
>  MODULE_DESCRIPTION(DRV_DESCRIPTION);
>  MODULE_AUTHOR(DRV_COPYRIGHT);
>  MODULE_LICENSE("GPL");
>  MODULE_VERSION(DRV_VERSION);
> +MODULE_FIRMWARE(FIRMWARE_D101M);
> +MODULE_FIRMWARE(FIRMWARE_D101S);
> +MODULE_FIRMWARE(FIRMWARE_D102E);
>
>  static int debug = 3;
>  static int eeprom_bad_csum_allow = 0;
> @@ -1049,178 +1057,6 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
>                c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
>  }
>
> -/********************************************************/
> -/*  Micro code for 8086:1229 Rev 8                      */
> -/********************************************************/
> -
> -/*  Parameter values for the D101M B-step  */
> -#define D101M_CPUSAVER_TIMER_DWORD             78
> -#define D101M_CPUSAVER_BUNDLE_DWORD            65
> -#define D101M_CPUSAVER_MIN_SIZE_DWORD          126
> -
> -#define D101M_B_RCVBUNDLE_UCODE \
> -{\
> -0x00550215, 0xFFFF0437, 0xFFFFFFFF, 0x06A70789, 0xFFFFFFFF, 0x0558FFFF, \
> -0x000C0001, 0x00101312, 0x000C0008, 0x00380216, \
> -0x0010009C, 0x00204056, 0x002380CC, 0x00380056, \
> -0x0010009C, 0x00244C0B, 0x00000800, 0x00124818, \
> -0x00380438, 0x00000000, 0x00140000, 0x00380555, \
> -0x00308000, 0x00100662, 0x00100561, 0x000E0408, \
> -0x00134861, 0x000C0002, 0x00103093, 0x00308000, \
> -0x00100624, 0x00100561, 0x000E0408, 0x00100861, \
> -0x000C007E, 0x00222C21, 0x000C0002, 0x00103093, \
> -0x00380C7A, 0x00080000, 0x00103090, 0x00380C7A, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x0010009C, 0x00244C2D, 0x00010004, 0x00041000, \
> -0x003A0437, 0x00044010, 0x0038078A, 0x00000000, \
> -0x00100099, 0x00206C7A, 0x0010009C, 0x00244C48, \
> -0x00130824, 0x000C0001, 0x00101213, 0x00260C75, \
> -0x00041000, 0x00010004, 0x00130826, 0x000C0006, \
> -0x002206A8, 0x0013C926, 0x00101313, 0x003806A8, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00080600, 0x00101B10, 0x00050004, 0x00100826, \
> -0x00101210, 0x00380C34, 0x00000000, 0x00000000, \
> -0x0021155B, 0x00100099, 0x00206559, 0x0010009C, \
> -0x00244559, 0x00130836, 0x000C0000, 0x00220C62, \
> -0x000C0001, 0x00101B13, 0x00229C0E, 0x00210C0E, \
> -0x00226C0E, 0x00216C0E, 0x0022FC0E, 0x00215C0E, \
> -0x00214C0E, 0x00380555, 0x00010004, 0x00041000, \
> -0x00278C67, 0x00040800, 0x00018100, 0x003A0437, \
> -0x00130826, 0x000C0001, 0x00220559, 0x00101313, \
> -0x00380559, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00130831, 0x0010090B, 0x00124813, \
> -0x000CFF80, 0x002606AB, 0x00041000, 0x00010004, \
> -0x003806A8, 0x00000000, 0x00000000, 0x00000000, \
> -}
> -
> -/********************************************************/
> -/*  Micro code for 8086:1229 Rev 9                      */
> -/********************************************************/
> -
> -/*  Parameter values for the D101S  */
> -#define D101S_CPUSAVER_TIMER_DWORD             78
> -#define D101S_CPUSAVER_BUNDLE_DWORD            67
> -#define D101S_CPUSAVER_MIN_SIZE_DWORD          128
> -
> -#define D101S_RCVBUNDLE_UCODE \
> -{\
> -0x00550242, 0xFFFF047E, 0xFFFFFFFF, 0x06FF0818, 0xFFFFFFFF, 0x05A6FFFF, \
> -0x000C0001, 0x00101312, 0x000C0008, 0x00380243, \
> -0x0010009C, 0x00204056, 0x002380D0, 0x00380056, \
> -0x0010009C, 0x00244F8B, 0x00000800, 0x00124818, \
> -0x0038047F, 0x00000000, 0x00140000, 0x003805A3, \
> -0x00308000, 0x00100610, 0x00100561, 0x000E0408, \
> -0x00134861, 0x000C0002, 0x00103093, 0x00308000, \
> -0x00100624, 0x00100561, 0x000E0408, 0x00100861, \
> -0x000C007E, 0x00222FA1, 0x000C0002, 0x00103093, \
> -0x00380F90, 0x00080000, 0x00103090, 0x00380F90, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x0010009C, 0x00244FAD, 0x00010004, 0x00041000, \
> -0x003A047E, 0x00044010, 0x00380819, 0x00000000, \
> -0x00100099, 0x00206FFD, 0x0010009A, 0x0020AFFD, \
> -0x0010009C, 0x00244FC8, 0x00130824, 0x000C0001, \
> -0x00101213, 0x00260FF7, 0x00041000, 0x00010004, \
> -0x00130826, 0x000C0006, 0x00220700, 0x0013C926, \
> -0x00101313, 0x00380700, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00080600, 0x00101B10, 0x00050004, 0x00100826, \
> -0x00101210, 0x00380FB6, 0x00000000, 0x00000000, \
> -0x002115A9, 0x00100099, 0x002065A7, 0x0010009A, \
> -0x0020A5A7, 0x0010009C, 0x002445A7, 0x00130836, \
> -0x000C0000, 0x00220FE4, 0x000C0001, 0x00101B13, \
> -0x00229F8E, 0x00210F8E, 0x00226F8E, 0x00216F8E, \
> -0x0022FF8E, 0x00215F8E, 0x00214F8E, 0x003805A3, \
> -0x00010004, 0x00041000, 0x00278FE9, 0x00040800, \
> -0x00018100, 0x003A047E, 0x00130826, 0x000C0001, \
> -0x002205A7, 0x00101313, 0x003805A7, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00130831, \
> -0x0010090B, 0x00124813, 0x000CFF80, 0x00260703, \
> -0x00041000, 0x00010004, 0x00380700  \
> -}
> -
> -/********************************************************/
> -/*  Micro code for the 8086:1229 Rev F/10               */
> -/********************************************************/
> -
> -/*  Parameter values for the D102 E-step  */
> -#define D102_E_CPUSAVER_TIMER_DWORD            42
> -#define D102_E_CPUSAVER_BUNDLE_DWORD           54
> -#define D102_E_CPUSAVER_MIN_SIZE_DWORD         46
> -
> -#define     D102_E_RCVBUNDLE_UCODE \
> -{\
> -0x007D028F, 0x0E4204F9, 0x14ED0C85, 0x14FA14E9, 0x0EF70E36, 0x1FFF1FFF, \
> -0x00E014B9, 0x00000000, 0x00000000, 0x00000000, \
> -0x00E014BD, 0x00000000, 0x00000000, 0x00000000, \
> -0x00E014D5, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00E014C1, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00E014C8, 0x00000000, 0x00000000, 0x00000000, \
> -0x00200600, 0x00E014EE, 0x00000000, 0x00000000, \
> -0x0030FF80, 0x00940E46, 0x00038200, 0x00102000, \
> -0x00E00E43, 0x00000000, 0x00000000, 0x00000000, \
> -0x00300006, 0x00E014FB, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00906E41, 0x00800E3C, 0x00E00E39, 0x00000000, \
> -0x00906EFD, 0x00900EFD, 0x00E00EF8, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -0x00000000, 0x00000000, 0x00000000, 0x00000000, \
> -}
> -
> -static void e100_setup_ucode(struct nic *nic, struct cb *cb, struct sk_buff *skb)
> -{
> -/* *INDENT-OFF* */
> -       static struct {
> -               u32 ucode[UCODE_SIZE + 1];
> -               u8 mac;
> -               u8 timer_dword;
> -               u8 bundle_dword;
> -               u8 min_size_dword;
> -       } ucode_opts[] = {
> -               { D101M_B_RCVBUNDLE_UCODE,
> -                 mac_82559_D101M,
> -                 D101M_CPUSAVER_TIMER_DWORD,
> -                 D101M_CPUSAVER_BUNDLE_DWORD,
> -                 D101M_CPUSAVER_MIN_SIZE_DWORD },
> -               { D101S_RCVBUNDLE_UCODE,
> -                 mac_82559_D101S,
> -                 D101S_CPUSAVER_TIMER_DWORD,
> -                 D101S_CPUSAVER_BUNDLE_DWORD,
> -                 D101S_CPUSAVER_MIN_SIZE_DWORD },
> -               { D102_E_RCVBUNDLE_UCODE,
> -                 mac_82551_F,
> -                 D102_E_CPUSAVER_TIMER_DWORD,
> -                 D102_E_CPUSAVER_BUNDLE_DWORD,
> -                 D102_E_CPUSAVER_MIN_SIZE_DWORD },
> -               { D102_E_RCVBUNDLE_UCODE,
> -                 mac_82551_10,
> -                 D102_E_CPUSAVER_TIMER_DWORD,
> -                 D102_E_CPUSAVER_BUNDLE_DWORD,
> -                 D102_E_CPUSAVER_MIN_SIZE_DWORD },
> -               { {0}, 0, 0, 0, 0}
> -       }, *opts;
> -/* *INDENT-ON* */
> -
>  /*************************************************************************
>  *  CPUSaver parameters
>  *
> @@ -1280,42 +1116,101 @@ static void e100_setup_ucode(struct nic *nic, struct cb *cb, struct sk_buff *skb
>  #define BUNDLEMAX (u16)6
>  #define INTDELAY (u16)1536 /* 0x600 */
>
> +/* Initialize firmware */
> +static const struct firmware *e100_request_firmware(struct nic *nic)
> +{
> +       const char *fw_name;
> +       const struct firmware *fw;
> +       u8 timer, bundle, min_size;
> +       int err;
> +
>        /* do not load u-code for ICH devices */
>        if (nic->flags & ich)
> -               goto noloaducode;
> +               return NULL;
>
>        /* Search for ucode match against h/w revision */
> -       for (opts = ucode_opts; opts->mac; opts++) {
> -               int i;
> -               u32 *ucode = opts->ucode;
> -               if (nic->mac != opts->mac)
> -                       continue;
> -
> -               /* Insert user-tunable settings */
> -               ucode[opts->timer_dword] &= 0xFFFF0000;
> -               ucode[opts->timer_dword] |= INTDELAY;
> -               ucode[opts->bundle_dword] &= 0xFFFF0000;
> -               ucode[opts->bundle_dword] |= BUNDLEMAX;
> -               ucode[opts->min_size_dword] &= 0xFFFF0000;
> -               ucode[opts->min_size_dword] |= (BUNDLESMALL) ? 0xFFFF : 0xFF80;
> -
> -               for (i = 0; i < UCODE_SIZE; i++)
> -                       cb->u.ucode[i] = cpu_to_le32(ucode[i]);
> -               cb->command = cpu_to_le16(cb_ucode | cb_el);
> -               return;
> -       }
> -
> -noloaducode:
> -       cb->command = cpu_to_le16(cb_nop | cb_el);
> -}
> -
> -static inline int e100_exec_cb_wait(struct nic *nic, struct sk_buff *skb,
> -       void (*cb_prepare)(struct nic *, struct cb *, struct sk_buff *))
> -{
> +       if (nic->mac == mac_82559_D101M)
> +               fw_name = FIRMWARE_D101M;
> +       else if (nic->mac == mac_82559_D101S)
> +               fw_name = FIRMWARE_D101S;
> +       else if (nic->mac == mac_82551_F || nic->mac == mac_82551_10)
> +               fw_name = FIRMWARE_D102E;
> +       else /* No ucode on other devices */
> +               return NULL;
> +
> +       err = request_firmware(&fw, fw_name, &nic->pdev->dev);
> +       if (err) {
> +               DPRINTK(PROBE, ERR, "Failed to load firmware \"%s\": %d\n",
> +                       fw_name, err);
> +               return ERR_PTR(err);
> +       }
> +       /* Firmware should be precisely UCODE_SIZE (words) plus three bytes
> +          indicating the offsets for BUNDLESMALL, BUNDLEMAX, INTDELAY */
> +       if (fw->size != UCODE_SIZE * 4 + 3) {
> +               DPRINTK(PROBE, ERR, "Firmware \"%s\" has wrong size %zu\n",
> +                       fw_name, fw->size);
> +               release_firmware(fw);
> +               return ERR_PTR(-EINVAL);
> +       }
> +
> +       /* Read timer, bundle and min_size from end of firmware blob */
> +       timer = fw->data[UCODE_SIZE * 4];
> +       bundle = fw->data[UCODE_SIZE * 4 + 1];
> +       min_size = fw->data[UCODE_SIZE * 4 + 2];
> +
> +       if (timer >= UCODE_SIZE || bundle >= UCODE_SIZE ||
> +           min_size >= UCODE_SIZE) {
> +               DPRINTK(PROBE, ERR,
> +                       "\"%s\" has bogus offset values (0x%x,0x%x,0x%x)\n",
> +                       fw_name, timer, bundle, min_size);
> +               release_firmware(fw);
> +               return ERR_PTR(-EINVAL);
> +       }
> +       /* OK, firmware is validated and ready to use... */
> +       return fw;
> +}
> +
> +static void e100_setup_ucode(struct nic *nic, struct cb *cb,
> +                            struct sk_buff *skb)
> +{
> +       const struct firmware *fw = (void *)skb;
> +       u8 timer, bundle, min_size;
> +
> +       /* It's not a real skb; we just abused the fact that e100_exec_cb
> +          will pass it through to here... */
> +       cb->skb = NULL;
> +
> +       /* firmware is stored as little endian already */
> +       memcpy(cb->u.ucode, fw->data, UCODE_SIZE * 4);
> +
> +       /* Read timer, bundle and min_size from end of firmware blob */
> +       timer = fw->data[UCODE_SIZE * 4];
> +       bundle = fw->data[UCODE_SIZE * 4 + 1];
> +       min_size = fw->data[UCODE_SIZE * 4 + 2];
> +
> +       /* Insert user-tunable settings in cb->u.ucode */
> +       cb->u.ucode[timer] &= cpu_to_le32(0xFFFF0000);
> +       cb->u.ucode[timer] |= cpu_to_le32(INTDELAY);
> +       cb->u.ucode[bundle] &= cpu_to_le32(0xFFFF0000);
> +       cb->u.ucode[bundle] |= cpu_to_le32(BUNDLEMAX);
> +       cb->u.ucode[min_size] &= cpu_to_le32(0xFFFF0000);
> +       cb->u.ucode[min_size] |= cpu_to_le32((BUNDLESMALL) ? 0xFFFF : 0xFF80);
> +
> +       cb->command = cpu_to_le16(cb_ucode | cb_el);
> +}
> +
> +static inline int e100_load_ucode_wait(struct nic *nic)
> +{
> +       const struct firmware *fw;
>        int err = 0, counter = 50;
>        struct cb *cb = nic->cb_to_clean;
>
> -       if ((err = e100_exec_cb(nic, NULL, e100_setup_ucode)))
> +       fw = e100_request_firmware(nic);
> +       /* If it's NULL, then no ucode is required */
> +       if (!fw || IS_ERR(fw))
> +               return PTR_ERR(fw);
> +
> +       if ((err = e100_exec_cb(nic, (void *)fw, e100_setup_ucode)))
>                DPRINTK(PROBE,ERR, "ucode cmd failed with error %d\n", err);
>
>        /* must restart cuc */
> @@ -1435,7 +1330,7 @@ static int e100_hw_init(struct nic *nic)
>                return err;
>        if((err = e100_exec_cmd(nic, ruc_load_base, 0)))
>                return err;
> -       if ((err = e100_exec_cb_wait(nic, NULL, e100_setup_ucode)))
> +       if ((err = e100_load_ucode_wait(nic)))
>                return err;
>        if((err = e100_exec_cb(nic, NULL, e100_configure)))
>                return err;
> diff --git a/firmware/Makefile b/firmware/Makefile
> index 4993a4b..d99000d 100644
> --- a/firmware/Makefile
> +++ b/firmware/Makefile
> @@ -28,6 +28,8 @@ fw-shipped-$(CONFIG_CHELSIO_T3) += cxgb3/t3b_psram-1.1.0.bin \
>                                   cxgb3/t3c_psram-1.1.0.bin \
>                                   cxgb3/t3fw-7.0.0.bin
>  fw-shipped-$(CONFIG_DVB_TTUSB_BUDGET) += ttusb-budget/dspbootcode.bin
> +fw-shipped-$(CONFIG_E100) += e100/d101m_ucode.bin e100/d101s_ucode.bin \
> +                            e100/d102e_ucode.bin
>  fw-shipped-$(CONFIG_SMCTR) += tr_smctr.bin
>  fw-shipped-$(CONFIG_SND_KORG1212) += korg/k1212.dsp
>  fw-shipped-$(CONFIG_SND_MAESTRO3) += ess/maestro3_assp_kernel.fw \
> diff --git a/firmware/WHENCE b/firmware/WHENCE
> index 8f06639..040967f 100644
> --- a/firmware/WHENCE
> +++ b/firmware/WHENCE
> @@ -360,3 +360,14 @@ License: GPLv2 or OpenIB.org BSD license, no source visible
>
>  --------------------------------------------------------------------------
>
> +Driver: e100 -- Intel PRO/100 Ethernet NIC
> +
> +File: e100/d101m_ucode.bin
> +File: e100/d101s_ucode.bin
> +File: e100/d102e_ucode.bin
> +
> +Licence: Unknown
> +
> +Found in hex form in kernel source.
> +
> +--------------------------------------------------------------------------
> diff --git a/firmware/e100/d101m_ucode.bin.ihex b/firmware/e100/d101m_ucode.bin.ihex
> new file mode 100644
> index 0000000..12971ed
> --- /dev/null
> +++ b/firmware/e100/d101m_ucode.bin.ihex
> @@ -0,0 +1,38 @@
> +:10000000150255003704FFFFFFFFFFFF8907A70612
> +:10001000FFFFFFFFFFFF580501000C001213100047
> +:1000200008000C00160238009C001000564020000A
> +:10003000CC802300560038009C0010000B4C24009C
> +:1000400000080000184812003804380000000000C2
> +:1000500000001400550538000080300062061000D2
> +:100060006105100008040E006148130002000C0036
> +:10007000933010000080300024061000610510004D
> +:1000800008040E00610810007E000C00212C2200E4
> +:1000900002000C00933010007A0C380000000800B9
> +:1000A000903010007A0C38000000000000000000C2
> +:1000B00000000000000000009C0010002D4C2400F7
> +:1000C000040001000010040037043A00104004004E
> +:1000D0008A07380000000000990010007A6C2000A8
> +:1000E0009C001000484C24002408130001000C0060
> +:1000F00013121000750C260000100400040001000B
> +:100100002608130006000C00A806220026C91300CA
> +:1001100013131000A80638000000000000000000C3
> +:1001200000000000000000000000000000000000CF
> +:10013000000000000000000000060800101B100076
> +:10014000040005002608100010121000340C3800BE
> +:1001500000000000000000005B1521009900100065
> +:10016000596520009C0010005945240036081300F2
> +:1001700000000C00620C220001000C00131B100098
> +:100180000E9C22000E0C21000E6C22000E6C210031
> +:100190000EFC22000E5C21000E4C2100550538009B
> +:1001A0000400010000100400678C27000008040010
> +:1001B0000081010037043A002608130001000C00FA
> +:1001C00059052200131310005905380000000000E3
> +:1001D000000000000000000000000000000000001F
> +:1001E00000000000000000000000000031081300C3
> +:1001F0000B0910001348120080FF0C00AB0626000C
> +:100200000010040004000100A806380000000000EF
> +:0B02100000000000000000004E417ED6
> +:00000001FF
> +/********************************************************/
> +/*  Micro code for 8086:1229 Rev 8                      */
> +/********************************************************/
> diff --git a/firmware/e100/d101s_ucode.bin.ihex b/firmware/e100/d101s_ucode.bin.ihex
> new file mode 100644
> index 0000000..102c7fe
> --- /dev/null
> +++ b/firmware/e100/d101s_ucode.bin.ihex
> @@ -0,0 +1,38 @@
> +:10000000420255007E04FFFFFFFFFFFF1808FF06B6
> +:10001000FFFFFFFFFFFFA60501000C0012131000F9
> +:1000200008000C00430238009C00100056402000DD
> +:10003000D0802300560038009C0010008B4F240015
> +:1000400000080000184812007F043800000000007B
> +:1000500000001400A30538000080300010061000D6
> +:100060006105100008040E006148130002000C0036
> +:10007000933010000080300024061000610510004D
> +:1000800008040E00610810007E000C00A12F220061
> +:1000900002000C0093301000900F380000000800A0
> +:1000A00090301000900F38000000000000000000A9
> +:1000B00000000000000000009C001000AD4F240074
> +:1000C00004000100001004007E043A001040040007
> +:1000D000190838000000000099001000FD6F200092
> +:1000E0009A001000FDAF20009C001000C84F2400B3
> +:1000F0002408130001000C0013121000F70F260053
> +:1001000000100400040001002608130006000C0083
> +:100110000007220026C9130013131000000738003F
> +:1001200000000000000000000000000000000000CF
> +:10013000000000000000000000060800101B100076
> +:10014000040005002608100010121000B60F380039
> +:100150000000000000000000A91521009900100017
> +:10016000A76520009A001000A7A520009C001000A1
> +:10017000A74524003608130000000C00E40F2200FD
> +:1001800001000C00131B10008E9F22008E0F210017
> +:100190008E6F22008E6F21008EFF22008E5F210065
> +:1001A0008E4F2100A3053800040001000010040058
> +:1001B000E98F270000080400008101007E043A0056
> +:1001C0002608130001000C00A705220013131000DD
> +:1001D000A70538000000000000000000000000003B
> +:1001E000000000000000000000000000000000000F
> +:1001F00000000000310813000B0910001348120022
> +:1002000080FF0C000307260000100400040001001A
> +:0B02100000073800000000004E438093
> +:00000001FF
> +/********************************************************/
> +/*  Micro code for 8086:1229 Rev 9                      */
> +/********************************************************/
> diff --git a/firmware/e100/d102e_ucode.bin.ihex b/firmware/e100/d102e_ucode.bin.ihex
> new file mode 100644
> index 0000000..9e806da
> --- /dev/null
> +++ b/firmware/e100/d102e_ucode.bin.ihex
> @@ -0,0 +1,38 @@
> +:100000008F027D00F904420E850CED14E914FA14F8
> +:10001000360EF70EFF1FFF1FB914E00000000000AE
> +:100020000000000000000000BD14E000000000001F
> +:100030000000000000000000D514E00000000000F7
> +:1000400000000000000000000000000000000000B0
> +:100050000000000000000000C114E00000000000EB
> +:100060000000000000000000000000000000000090
> +:100070000000000000000000000000000000000080
> +:100080000000000000000000000000000000000070
> +:100090000000000000000000C814E00000000000A4
> +:1000A000000000000000000000062000EE14E00048
> +:1000B000000000000000000080FF3000460E9400A9
> +:1000C0000082030000201000430EE000000000004A
> +:1000D000000000000000000006003000FB14E000FB
> +:1000E0000000000000000000000000000000000010
> +:1000F0000000000000000000000000000000000000
> +:1001000000000000000000000000000000000000EF
> +:100110000000000000000000416E90003C0E8000D6
> +:10012000390EE00000000000FD6E9000FD0E900012
> +:10013000F80EE000000000000000000000000000D9
> +:1001400000000000000000000000000000000000AF
> +:10015000000000000000000000000000000000009F
> +:10016000000000000000000000000000000000008F
> +:10017000000000000000000000000000000000007F
> +:10018000000000000000000000000000000000006F
> +:10019000000000000000000000000000000000005F
> +:1001A000000000000000000000000000000000004F
> +:1001B000000000000000000000000000000000003F
> +:1001C000000000000000000000000000000000002F
> +:1001D000000000000000000000000000000000001F
> +:1001E000000000000000000000000000000000000F
> +:1001F00000000000000000000000000000000000FF
> +:1002000000000000000000000000000000000000EE
> +:0B02100000000000000000002A362E55
> +:00000001FF
> +/********************************************************/
> +/*  Micro code for the 8086:1229 Rev F/10               */
> +/********************************************************/
> --
> 1.5.5.1
>

Please hold off on committing, until we have had ample time to do some
regression testing.  While this patch may have been in linux-next,
this is the first we have seen of it.

I am concerned that IPMI traffic will be adversely affected by this patch.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------

From: Myron Stowe <myron.stowe@gmail.com>
Subject: Re: [PATCH 0/2] Replace driver's usage of hard-coded device IDs to #defines
Date: Fri, 16 Jun 2017 14:21:07 -0600
Message-ID: <CAL-B5D3xY4g4cd4ermTGfK6_5GosWwB-qyr8TS6QTdxPiQ3Amg@mail.gmail.com>
References: <20170524224734.24221.33787.stgit@amt.stowe> <20170524.200249.1492095559302424098.davem@davemloft.net>
 <20170525095655.3a577ea2@zim> <20170616200820.GE11129@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Myron Stowe <mstowe@redhat.com>,
        David Miller <davem@davemloft.net>,
        Myron Stowe <myron.stowe@redhat.com>,
        linux-pci <linux-pci@vger.kernel.org>, netdev@vger.kernel.org,
        Bjorn Helgaas <bhelgaas@google.com>, saeedm@mellanox.com,
        noaos@mellanox.com, tariqt@mellanox.com
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33784 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdFPUVJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 16:21:09 -0400
In-Reply-To: <20170616200820.GE11129@bhelgaas-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 16, 2017 at 2:08 PM, Bjorn Helgaas <helgaas@kernel.org> wrote:
> On Thu, May 25, 2017 at 09:56:55AM -0600, Myron Stowe wrote:
>> On Wed, 24 May 2017 20:02:49 -0400 (EDT)
>> David Miller <davem@davemloft.net> wrote:
>>
>> > From: Myron Stowe <myron.stowe@redhat.com>
>> > Date: Wed, 24 May 2017 16:47:34 -0600
>> >
>> > > Noa Osherovich introduced a series of new Mellanox device ID
>> > > definitions to help differentiate specific controllers that needed
>> > > INTx masking quirks [1].
>> > >
>> > > Bjorn Helgaas followed on, using the device ID definitions Noa
>> > > provided to replace hard-coded values within the mxl4 ID table [2].
>> > >
>> > > This patch continues along similar lines, adding a few additional
>> > > Mellanox device ID definitions and converting the net/mlx5e
>> > > driver's mlx5 ID table to use the defines so tools like 'grep' and
>> > > 'cscope' can be used to help identify relationships with other
>> > > aspects (such as INTx masking).
>> >
>> > If you're adding pci_ids.h defines, it's only valid to do so if you
>> > actually use the defines in more than one location.
>> >
>> > This patch series is not doing that.
>>
>> Hi David,
>>
>> Yes, now that you mention that again I do vaguely remember past
>> conversations stating similar constraints which is a little odd as
>> Noa's series did exactly that.  It was Bjorn, in a separate patch, that
>> made the connection to the driver with commit c19e4b9037f
>> ("net/mlx4_core: Use device ID defines") [1] and even after such, some
>> of the introduced #defines are still currently singular in usage.
>>
>> Anyway, the part I'm interested in is creating a more transparent
>> association between the Mellanox controllers that need the INTx masking
>> quirk and their drivers, something that remains very opaque currently
>> for a few of the remaining instances (PCI_DEVICE_ID_MELLANOX_CONNECTIB,
>> PCI_DEVICE_ID_MELLANOX_CONNECTX4, and
>> PCI_DEVICE_ID_MELLANOX_CONNECTX4_LX).
>
> I think what you want is the patch below (your patch 2, after removing
> CONNECTX5, CONNECTX5_EX, and CONNECTX6 since they're only used in one
> place).
>
> We added definitions for CONNECTIB, CONNECTX4, and CONNECTX4_LX and uses of
> them in a quirk via:
>
>   7254383341bc ("PCI: Add Mellanox device IDs")
>   d76d2fe05fd9 ("PCI: Convert Mellanox broken INTx quirks to be for listed
>   devices only")
>
> But somehow we missed using those in mlx5/core/main.c.

Yes, that's the downside to not adding pci_ids.h defines originally
within the driver when its written (even if they are only used once),
it ends up putting the burden on subsequent patch generators to notice
the association and clean things up after the fact.  :)

>
> The patch below doesn't touch PCI, so it would be just for netdev.

Yes, without the pci_ids.h #defines, the resulting patch just ends up
being for netdev.  That's fine, it was the association between the
quirk and the driver, wanting to make such more transparent, that was
the inpetus for this.

>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> index 0c123d571b4c..8a4e292f26b8 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> @@ -1508,11 +1508,11 @@ static void shutdown(struct pci_dev *pdev)
>  }
>
>  static const struct pci_device_id mlx5_core_pci_table[] = {
> -       { PCI_VDEVICE(MELLANOX, 0x1011) },                      /* Connect-IB */
> +       { PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTIB) },
>         { PCI_VDEVICE(MELLANOX, 0x1012), MLX5_PCI_DEV_IS_VF},   /* Connect-IB VF */
> -       { PCI_VDEVICE(MELLANOX, 0x1013) },                      /* ConnectX-4 */
> +       { PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTX4) },
>         { PCI_VDEVICE(MELLANOX, 0x1014), MLX5_PCI_DEV_IS_VF},   /* ConnectX-4 VF */
> -       { PCI_VDEVICE(MELLANOX, 0x1015) },                      /* ConnectX-4LX */
> +       { PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTX4_LX) },
>         { PCI_VDEVICE(MELLANOX, 0x1016), MLX5_PCI_DEV_IS_VF},   /* ConnectX-4LX VF */
>         { PCI_VDEVICE(MELLANOX, 0x1017) },                      /* ConnectX-5, PCIe 3.0 */
>         { PCI_VDEVICE(MELLANOX, 0x1018), MLX5_PCI_DEV_IS_VF},   /* ConnectX-5 VF */

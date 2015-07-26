From: Jiri Pirko <jiri@mellanox.com>
Subject: Re: [patch net-next 2/4] mlxsw: Add PCI bus implementation
Date: Sun, 26 Jul 2015 08:49:08 +0200
Message-ID: <20150726064908.GA2153@nanopsycho.fritz.box>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
 <1437666216-3149-3-git-send-email-jiri@resnulli.us>
 <CAE4R7bBGgXvYbaXFrQHnA=YX3KZHXi5T4aH=-UH81RUqUm4+vQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <idosch@mellanox.com>,
	<eladr@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Thomas Graf" <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	John Linville <linville@tuxdriver.com>,
	"Andy Gospodarek" <andy@greyhouse.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0064.outbound.protection.outlook.com ([157.56.112.64]:15712
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751460AbbGZHDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jul 2015 03:03:51 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bBGgXvYbaXFrQHnA=YX3KZHXi5T4aH=-UH81RUqUm4+vQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 26, 2015 at 07:15:04AM CEST, sfeldma@gmail.com wrote:
>On Thu, Jul 23, 2015 at 8:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Add PCI bus implementation for Mellanox Technologies Switch ASICs. This
>> includes firmware initialization, async queues manipulation and command
>> interface implementation.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Elad Raz <eladr@mellanox.com>
>> ---
>
>[cut]
>
>> +static int mlxsw_pci_fw_area_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
>> +                                 u16 num_pages)
>> +{
>> +       struct mlxsw_pci_mem_item *mem_item;
>> +       int i;
>> +       int err;
>
>Need to init err to zero here

You are right. We need to set err before "goto err_alloc". Thanks.


>
>> +
>> +       mlxsw_pci->fw_area.items = kcalloc(num_pages, sizeof(*mem_item),
>> +                                          GFP_KERNEL);
>> +       if (!mlxsw_pci->fw_area.items)
>> +               return -ENOMEM;
>> +       mlxsw_pci->fw_area.num_pages = num_pages;
>> +
>> +       mlxsw_cmd_mbox_zero(mbox);
>> +       for (i = 0; i < num_pages; i++) {
>> +               mem_item = &mlxsw_pci->fw_area.items[i];
>> +
>> +               mem_item->size = MLXSW_PCI_PAGE_SIZE;
>> +               mem_item->buf = pci_alloc_consistent(mlxsw_pci->pdev,
>> +                                                    mem_item->size,
>> +                                                    &mem_item->mapaddr);
>> +               if (!mem_item->buf)
>> +                       goto err_alloc;
>> +               mlxsw_cmd_mbox_map_fa_pa_set(mbox, i, mem_item->mapaddr);
>> +               mlxsw_cmd_mbox_map_fa_log2size_set(mbox, i, 0); /* 1 page */
>> +       }
>> +
>> +       err = mlxsw_cmd_map_fa(mlxsw_pci->core, mbox, num_pages);
>> +       if (err)
>> +               goto err_cmd_map_fa;
>> +
>> +       return 0;
>> +
>> +err_cmd_map_fa:
>> +err_alloc:
>> +       for (i--; i >= 0; i--) {
>> +               mem_item = &mlxsw_pci->fw_area.items[i];
>> +
>> +               pci_free_consistent(mlxsw_pci->pdev, mem_item->size,
>> +                                   mem_item->buf, mem_item->mapaddr);
>> +       }
>> +       kfree(mlxsw_pci->fw_area.items);
>> +       return err;
>> +}

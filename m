From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] linux/types.h: enable endian checks for all sparse builds
Date: Thu, 8 Dec 2016 18:17:32 +0200
Message-ID: <20161208163658-mutt-send-email-mst@kernel.org>
References: <1481164052-28036-1-git-send-email-mst@redhat.com>
 <BLUPR02MB168374E98A6C86E43DF0BCFE81840@BLUPR02MB1683.namprd02.prod.outlook.com>
 <20161208075152-mutt-send-email-mst@kernel.org>
 <BLUPR02MB168304F8FBA50C916A6A4E6081840@BLUPR02MB1683.namprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Jason Wang <jasowang@redhat.com>,
        "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>,
        Michal Marek <mmarek@suse.com>, Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Matt Mackall <mpm@selenic.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Airlie <airlied@linux.ie>,
        Gerd Hoffmann <kraxel@redhat.com>,
        Ohad Ben-Cohen <ohad@wizery.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Cornelia Huck <cornelia.huck@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>, Jens Axboe <axboe@fb.com>,
        Neil Armstrong <narmstron
To: Bart Van Assche <Bart.VanAssche@sandisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60928 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932360AbcLHQRm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 11:17:42 -0500
Content-Disposition: inline
In-Reply-To: <BLUPR02MB168304F8FBA50C916A6A4E6081840@BLUPR02MB1683.namprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 06:38:11AM +0000, Bart Van Assche wrote:
> On 12/07/16 21:54, Michael S. Tsirkin wrote:
> > On Thu, Dec 08, 2016 at 05:21:47AM +0000, Bart Van Assche wrote:
> >> Additionally, there are notable exceptions to the rule that most drivers
> >> are endian-clean, e.g. drivers/scsi/qla2xxx. I would appreciate it if it
> >> would remain possible to check such drivers with sparse without enabling
> >> endianness checks. Have you considered to change #ifdef __CHECK_ENDIAN__
> >> into e.g. #ifndef __DONT_CHECK_ENDIAN__?
> >
> > The right thing is probably just to fix these, isn't it?
> > Until then, why not just ignore the warnings?
> 
> Neither option is realistic. With endian-checking enabled the qla2xxx 
> driver triggers so many warnings that it becomes a real challenge to 
> filter the non-endian warnings out manually:
> 
> $ for f in "" CF=-D__CHECK_ENDIAN__; do make M=drivers/scsi/qla2xxx C=2\
>      $f | &grep -c ': warning:'; done
> 4
> 752

You can always revert this patch in your tree, or whatever.  It does not
look like this will get fixed otherwise.

> If you think it would be easy to fix the endian warnings triggered by 
> the qla2xxx driver, you are welcome to try to fix these.
> 
> Bart.

Yea, this hardware was designed by someone who thought mixing
LE and BE all over the place is a good idea.
But who said it should be easy?

Maybe this change will be enough to motivate the maintainers.

Here's a minor buglet for you as a motivator:

                        if (ct_rsp->header.response !=
                            cpu_to_be16(CT_ACCEPT_RESPONSE)) {
                                ql_dbg(ql_dbg_disc + ql_dbg_buffer, vha, 0x2077,
                                    "%s failed rejected request on port_id: %02x%02x%02x Compeltion status 0x%x, response 0x%x\n",
                                    routine, vha->d_id.b.domain,
                                    vha->d_id.b.area, vha->d_id.b.al_pa, comp_status, ct_rsp->header.response);


response is BE and isn't printed correctly.

another:

        eiter->a.max_frame_size = cpu_to_be32(eiter->a.max_frame_size);
        size += 4 + 4;

        ql_dbg(ql_dbg_disc, vha, 0x20bc,
            "Max_Frame_Size = %x.\n", eiter->a.max_frame_size);

printed too late, it's be by that time.

Here's another suspicious line

        ctio24->u.status1.flags = (atio->u.isp24.attr << 9) |
            cpu_to_le16(CTIO7_FLAGS_STATUS_MODE_1 |
                CTIO7_FLAGS_TERMINATE);

shifting attr by 9 bits gives different results on BE and LE,
mixing it with le16 looks rather strange.

Another:

                ha->flags.dport_enabled =
                    (mid_init_cb->init_cb.firmware_options_1 & BIT_7) != 0;

BIT_7 is native endian, firmware_options_1 is LE I think.



Look at qla27xx_find_valid_image as well.

        if (pri_image_status.signature != QLA27XX_IMG_STATUS_SIGN)

qla27xx_image_status seems to be data coming from flash, but is
somehow native-endian? Maybe ...


        lun = a->u.isp24.fcp_cmnd.lun;

I think lun here is in hardware format (le?), code treats it
as native.


Not to speak about interface abuse all over the place.
How about this:

uint32_t *
qla24xx_read_flash_data(scsi_qla_host_t *vha, uint32_t *dwptr, uint32_t
faddr,
    uint32_t dwords)                     
{
        uint32_t i;                     
        struct qla_hw_data *ha = vha->hw;
                                        
        /* Dword reads to flash. */
        for (i = 0; i < dwords; i++, faddr++)
                dwptr[i] = cpu_to_le32(qla24xx_read_flash_dword(ha,
                    flash_data_addr(ha, faddr)));

        return dwptr;                   
}

OK so we convert to LE ...

                qla24xx_read_flash_data(vha, dcode, faddr, 4); 
    
                risc_addr = be32_to_cpu(dcode[2]);
                *srisc_addr = *srisc_addr == 0 ? risc_addr : *srisc_addr;
                risc_size = be32_to_cpu(dcode[3]);

then happily assume it's BE.

And again, coming from flash, it's unlikely to actually be in the native
endian-ness as callers seem to assume. I'm guessing it's all BE.

I poked at it a bit and was able to cut down # of warnings
from 1700 to 1400 in an hour. Someone familiar with the code
should look at it.

-- 
MST

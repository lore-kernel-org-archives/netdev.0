From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 14:47:59 -0700
Message-ID: <1237844879.18617.20.camel@HP1>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
 <1237503884.16140.23.camel@HP1>
 <20090319232541.GA19262@wavehammer.waldi.eu.org>
 <20090320.155030.164080684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "waldi@debian.org" <waldi@debian.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"davem@davemloft.org" <davem@davemloft.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2884 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380AbZCWWBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 18:01:47 -0400
In-Reply-To: <20090320.155030.164080684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2009-03-20 at 15:50 -0700, David Miller wrote:
> From: Bastian Blank <waldi@debian.org>
> Date: Fri, 20 Mar 2009 00:25:41 +0100
> 
> > On Thu, Mar 19, 2009 at 04:04:44PM -0700, Michael Chan wrote:
> > > Thanks Ben and Bastian.  I will review this and test it out.  I think I
> > > will add some logic to check firmware versions to guarantee some level
> > > of compatibility.
> > 
> > The firmware version is coded into the filenames.
> 
> Michael and co. please do not make such a big deal about
> this.
> 
> This patch is perfectly fine as-is.
> 

Yes, the patch looks good.  I just noticed one problem while reviewing.
The following logic to let the firmware know about the host CPU's page
size is missing and I'll need to add it back.  Otherwise it will only
work on CPUs with 4K page size.

+static int
+load_rv2p_fw(struct bnx2 *bp, u32 rv2p_proc,
+            const struct bnx2_fw_file_section *fw_section)
+{
+       u32 rv2p_code_len, file_offset;
+       __be32 *rv2p_code;
        int i;
        u32 val;
 
-       if (rv2p_proc == RV2P_PROC2 && CHIP_NUM(bp) == CHIP_NUM_5709) {
-               val = le32_to_cpu(rv2p_code[XI_RV2P_PROC2_MAX_BD_PAGE_LOC]);
-               val &= ~XI_RV2P_PROC2_BD_PAGE_SIZE_MSK;
-               val |= XI_RV2P_PROC2_BD_PAGE_SIZE;
-               rv2p_code[XI_RV2P_PROC2_MAX_BD_PAGE_LOC] = cpu_to_le32(val);
-       }
+       rv2p_code_len = be32_to_cpu(fw_section->len);
+       file_offset = be32_to_cpu(fw_section->offset);
+
+       rv2p_code = (__be32 *)(bp->firmware->data + file_offset);


I'd also like to add the version information to the bnx2_fw_file_entry
struct instead of embedding it in the file name.  It is more flexible
this way as each section can have different versions and can be updated
separately.  So it will look something like:

struct bnx2_fw_file_entry {
	__be32 start_addr;
	__be32 version;
	struct bnx2_fw_file_section text;
	struct bnx2_fw_file_section data;
	struct bnx2_fw_file_section sbss;
	struct bnx2_fw_file_section bss;
	struct bnx2_fw_file_section rodata;
};


I'll generate an incremental patch on top of this one for review.
Thanks.

 



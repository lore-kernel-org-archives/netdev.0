From: John Wright <john.wright@hp.com>
Subject: bnx2x: Use request_firmware()
Date: Sat,  4 Apr 2009 16:15:12 -0600
Message-ID: <1238883314-13140-1-git-send-email-john.wright@hp.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:11024 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbZDDWPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 18:15:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Following is the "meat" of a patch series to make the bnx2x driver use
request_firmware().  I have omitted patches 1/4 and 4/4, which
respectively add the firmware in .ihex format to the firmware/ directory
and remove drivers/net/bnx2x_init_values.h, since each patch is just
over a megabyte, and less useful for review than 2/4 and 3/4.  The
complete patch series is available here [1].

A description of the firmware file format is in the first patch header:

    bnx2x: Add the firmware in ihex format
    
    This was derived from drivers/net/bnx2x_init_values.h.
    
    Each firmware file corresponds to a revision of the card (E1 or E1H).
    It is stored in little endian format and starts with a header:
    
        struct bnx2x_fw_file {
        	struct bnx2x_fw_file_section init_ops;
        	struct bnx2x_fw_file_section init_ops_offsets;
        	struct bnx2x_fw_file_section init_data;
        	struct bnx2x_fw_file_section tsem_int_table_data;
        	struct bnx2x_fw_file_section tsem_pram_data;
        	struct bnx2x_fw_file_section usem_int_table_data;
        	struct bnx2x_fw_file_section usem_pram_data;
        	struct bnx2x_fw_file_section csem_int_table_data;
        	struct bnx2x_fw_file_section csem_pram_data;
        	struct bnx2x_fw_file_section xsem_int_table_data;
        	struct bnx2x_fw_file_section xsem_pram_data;
        };
    
    Each member (except init_ops_offsets, more on that later) represents one
    of the arrays currently in bnx2x_init_values.h, and has the following
    structure:
    
        struct bnx2x_fw_file_section {
        	u32 len;
        	u32 offset;
        };
    
    Naturally, len gives the length in bytes of the data in that section,
    and offset indicates where data starts, relative to the beginning of the
    file.
    
    Now, the init_ops_offsets member exists because, currently, a bunch of
    operation or function offsets are given as #define's in
    bnx2x_init_values.h.  But since if the firmware changes, these offsets
    change too, they ought to go in the firmware file.  So we keep the
    offsets as an array of u32's in the firmware file, and we'll change the
    constants in the driver to be indices into this array instead of the
    actual offsets.
    
    Signed-off-by: John Wright <john.wright@hp.com>

One slightly tricky part is endianness.  I wrote the data to the
firmware file in little endian format.  The bnx2x author chose to store
the blobs as integer arrays instead of character arrays, so there's code
all over to byteswap on big endian architectures.  Rather than find all
those, I just made temporary buffers and byteswapped in
bnx2x_init_block() before passing the data to functions that would send
the data to the card.

The only exception here is for data given to bnx2x_init_wr_wb(), which
might not actually use the pointer given to it from bnx2x_init_block()
(note the line near the top of that function where it assigns to data).
So, I modified bnx2x_init_wr_wb() to assume it was given data in little
endian format, and byteswapped results as necessary in that function
before passing the data on to the functions that write the data to the
card.

Ideally, the code could be simplified by having the functions that send
firmware data to the card use char arrays instead of u32 arrays, to
avoid a lot of byteswapping on big endian architectures.  But this way
touches less code, and since this only happens at initialization time, I
don't think a "few" extra swab32's on big endian architectures will
hurt.


 drivers/net/Kconfig                 |    1 +
 drivers/net/bnx2x.h                 |   19 +
 drivers/net/bnx2x_init.h            |  401 +-
 drivers/net/bnx2x_init_values.h     |16322 -----------------------------------
 drivers/net/bnx2x_main.c            |   75 +
 firmware/Makefile                   |    1 +
 firmware/WHENCE                     |   20 +
 firmware/bnx2x-e1-1.48.105.fw.ihex  |10789 +++++++++++++++++++++++
 firmware/bnx2x-e1h-1.48.105.fw.ihex |12174 ++++++++++++++++++++++++++
 9 files changed, 23436 insertions(+), 16366 deletions(-)


commit 7942f34652bd614bc75ddea32feeca22094880e3 (omitted from email)
Author: John Wright <john.wright@hp.com>

    bnx2x: Add the firmware in ihex format

commit 1f69e9fcc9822cc69ab8672ea1d782338f4ad21a (PATCH 2/4)
Author: John Wright <john.wright@hp.com>

    bnx2x: Use request_firmware()

commit c8b95dffac22ceda88d267e3844a1023448deb1e (PATCH 3/4)
Author: John Wright <john.wright@hp.com>

    bnx2x: Get init_ops offsets from the firmware file

commit 2a0fb45fb5cc6846bd4953639f5103a78ee44d58 (omitted from email)
Author: John Wright <john.wright@hp.com>

    bnx2x: Remove unused bnx2x_init_values.h file


 [1]: http://free.linux.hp.com/~jswright/bnx2x_request_firmware/

-- 
+----------------------------------------------------------+
| John Wright <john.wright@hp.com>                         |
| HP Mission Critical OS Enablement & Solution Test (MOST) |
+----------------------------------------------------------+

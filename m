From: "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>
Subject: [PATCH UCC TDM 0/3] UCC based TDM driver for QE based MPC83xx platforms
Date: Thu, 24 Jan 2008 09:43:47 +0530
Message-ID: <FBA61160C48B8D438F3323FEFB4EF2C279AE51@zin33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Barkowski Michael" <Michael.Barkowski@freescale.com>,
	"Phillips Kim" <Kim.Phillips@freescale.com>,
	"Kalra Ashish" <ashish.kalra@freescale.com>,
	"Tabi Timur" <timur@freescale.com>,
	"Cutler Richard" <Rich.Cutler@freescale.com>
To: "Kumar Gala" <kumar.gala@freescale.com>,
	<akpm@linux-foundation.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <rubini@vision.unipv.it>,
	<linuxppc-dev@ozlabs.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754008AbYAXEOM@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Reworked patches after incorporating comments of Andrew, Stephen and
Tabi and Kumar.

Kumar could you please consider them for linux-2.6.25.

There are three patches
[PATCH 1/3] drivers/misc : UCC TDM driver for mpc83xx platforms. This
driver is usable in VoIP iind of applications to interface with SLIC
kind of devices to exchange TDM voice samples.
The driver is right now in misc category and exposes a kind of non
standard interface to the clients.

TDM Driver Interface Details

The TDM driver right now is a misc driver with no subsystem as such.

The dts file keeps a track of the TDM devices present on the board.
Depending on them the TDM driver initializes those many driver instances
while coming up.

The driver on the upper level can plug to more than one tdm clients
depending on the availablity of TDM devices.
At every new request of the TDM client to bind with a TDM device, a free
driver instance is allocated to the client.

The interface can be described as follows.

tdm_register_client(struct tdm_client *)
	This API returns a pointer to the structure tdm_client which is
of type
	struct tdm_client {
                u32 client_id;
                u32 (*tdm_read)(u32 client_id, short chn_id, short
*pcm_buffer, short len);
                u32 (*tdm_write)(u32 client_id, short chn_id, short
*pcm_buffer, short len);
                wait_queue_head_t *wakeup_event;
        }

   It consists of:
   - driver_handle: It is basically to identify the particular TDM
device/driver instance.
   - tdm_read: It is a function pointer returned by the TDM driver to be
used to read TDM data from a particular TDM channel.
   - tdm_write: It is a function pointer returned by the TDM driver to
be used to write TDM data to a particular TDM channel.
   - wakeup_event: It is address of a wait_queue event on which the
client keeps on sleeping, and the TDM driver wakes it up periodically.
The driver is configured to wake up the client after every 10ms.

Once the TDM client gets registered to a TDM driver instance and a TDM
device, it interfaces with the driver using tdm_read, tdm_write and
wakeup_event.

Note: The TDM driver can be used by only kernel level modules. The
driver does not expose any file interface for User Applications. Can be
compared to the spi driver which interfaces with the SPI clients(kernel
mode clients) through some APIs.

This interface can be improved by writing a platform independent TDM
layer. Then all the TDM platforms can be supported below this wrapper
layer. This is planned to be done later.

[PATCH 2/3] arch/ : Platform changes
- device tree entries for UCC TDM driver for MPC8323ERDB platform.
- QE changes related to TDM , like,
	 1) Modified ucc_fast_init so that it can be used by fast UCC
based TDM driver. Mainly changes have been made to configure TDM clocks
and Fsyncs.

	2) Modified get_brg_clk so that it can return the input frequncy
and input source of any BRG by reading the corresponding entries from
device tree.

	3) Added new nodes brg and clocks in the device tree which
represent input clocks for different BRGs.

	4) Modified qe_setbrg accordingly.
- new device tree entries added for "clocks" and "brg"

[PATCH 3/3] Documentation
- Modified Documentation to explain the device tree entries related to
UCC TDM driver and the new nodes added("clocks" and "brg")

The patch applies over a merge of galak's for-2.6.25 plus for-2.6.24
plus of_doc_update branches.
In brief the steps were
git clone
git://git.kernel.org/pub/scm/linux/kernel/git/galak/powerpc.git
powerpc-galak
git checkout -b for-2.6.25 origin/for-2.6.25 git checkout -b for-2.6.24
origin/for-2.6.24 git checkout -b of_doc_update origin/of_doc_update
git pull . for-2.6.24    # merge the other two
git pull . for-2.6.25 
git checkout -b tdm      # clean slate for tdm rebase work

Also after applying the patches changes have to be made corresponding to
Tabi's patch "qe: add function qe_clock_source".

The driver has been tested with a VoIP stack and application on
MPC8323ERDB.

With Regards
Poonam 
 

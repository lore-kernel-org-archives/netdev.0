From: Greg Banks <gnb@sgi.com>
Subject: tg3 DMA RW Control register settings
Date: Mon, 30 Aug 2004 19:22:11 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830092211.GB5745@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Development List <netdev@oss.sgi.com>,
        John Partridge <johnip@sgi.com>, Arthur Kepner <akepner@sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

G'day,

I'm trying to make sense of your tg3 driver cset

http://gkernel.bkbits.net:8080/net-drivers-2.6/cset@1.1587.25.23

which changes the values used to set up the DMA READ/WRITE CONTROL
register (0x6c) to handle PCI-X and PCI-E modes.  This is great!
At SGI we've got a performance issue with a 5704 in PCI-X mode which
may be related to exactly these settings, so having the driver do
the right thing would be good.  I just have a couple of questions.

1.  Are the values for the Write Boundary field in the PCI-E case
    correct?  The diff adds

#define  DMA_RWCTRL_WRITE_BNDRY_64_PCIE	 0x10000000
#define  DMA_RWCTRL_WRITE_BNDRY_128_PCIE 0x30000000
#define  DMA_RWCTRL_WRITE_BNDRY_DISAB_PCIE 0x70000000

    but these seem to set the Default PCI Write field instead.
    It seems to me (based on version PG101-R of the manual) that
    the right values would be

#define  DMA_RWCTRL_WRITE_BNDRY_64_PCIE	   0x00000000
#define  DMA_RWCTRL_WRITE_BNDRY_128_PCIE   0x00000800
#define  DMA_RWCTRL_WRITE_BNDRY_DISAB_PCIE 0x00001800

2.  The Write Boundary field has a whole bunch of code to set it
    up.  The Read Boundary field is never set and defaults to 0
    (=disabled for PCI and PCI-X). Is this deliberate?

3.  The new code seems to use a lot of 32bit magic numbers, for
    which #defines already exist in the header.  Ummm....?

4.  Is there any explanation of how the following were chosen
    (assuming cache size of 128 bytes) ?

    DMA Write Watermark:        0b11 => 384 bytes
    DMA Read Watermark:         0b111 => 1536 bytes
    DMA Write Address Boundary: 0b11 => 384 bytes
    DMA Read Address Boundary:  0b00 => disabled
    One DMA at Once:            0b01

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH v1 RFC 1/1] Add Microchip KSZ8795 DSA driver
Date: Wed, 18 Oct 2017 17:55:17 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41131990@CHN-SV-EXMX02.mchp-main.com>
References: <1507322023-15182-1-git-send-email-Tristram.Ha@microchip.com>
 <1507322023-15182-2-git-send-email-Tristram.Ha@microchip.com>
 <20171011205916.GC31288@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <ruediger.schmitt@philips.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011205916.GC31288@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static void ksz8795_r_mib_cnt(struct ksz_device *dev, int port, u16 addr,
> > +			      u64 *cnt)
> > +{
> > +	u32 data;
> > +	u16 ctrl_addr;
> > +	u8 check;
> > +	int loop;
> > +
> > +	ctrl_addr = addr + SWITCH_COUNTER_NUM * port;
> > +	ctrl_addr |= IND_ACC_TABLE(TABLE_MIB | TABLE_READ);
> > +
> > +	mutex_lock(&dev->alu_mutex);
> > +	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
> > +
> > +	/* It is almost guaranteed to always read the valid bit because of
> > +	 * slow SPI speed.
> > +	 */
> > +	for (loop = 2; loop > 0; loop--) {
> > +		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
> > +
> > +		if (check & MIB_COUNTER_VALID) {
> > +			ksz_read32(dev, REG_IND_DATA_LO, &data);
> > +			if (check & MIB_COUNTER_OVERFLOW)
> > +				*cnt += MIB_COUNTER_VALUE + 1;
> > +			*cnt += data & MIB_COUNTER_VALUE;
> > +			break;
> > +		}
> > +	}
> 
> Hmm. Maybe, but should not this at least warn if if it can not get
> valid counter?
>

The checking of valid bit is implemented because of the chip datasheet.
But in my experience it never happens.   A warning will be added, although I
do not see any benefit of it.  It this warning ever comes up it just means
somehow the SPI access is completely broken down.
 
> > +	/* It is almost guaranteed to always read the valid bit because of
> > +	 * slow SPI speed.
> > +	 */
> > +	for (loop = 2; loop > 0; loop--) {
> > +		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
> > +
> > +		if (check & MIB_COUNTER_VALID) {
> > +			ksz_read32(dev, REG_IND_DATA_LO, &data);
> > +			if (addr < 2) {
> > +				u64 total;
> > +
> > +				total = check & MIB_TOTAL_BYTES_H;
> > +				total <<= 32;
> > +				*cnt += total;
> > +				*cnt += data;
> > +				if (check & MIB_COUNTER_OVERFLOW) {
> > +					total = MIB_TOTAL_BYTES_H + 1;
> > +					total <<= 32;
> > +					*cnt += total;
> > +				}
> > +			} else {
> > +				if (check & MIB_COUNTER_OVERFLOW)
> > +					*cnt += MIB_PACKET_DROPPED + 1;
> > +				*cnt += data & MIB_PACKET_DROPPED;
> > +			}
> > +			break;
> > +		}
> > +	}
> 
> Same here. Plus, is overflow handling correct? There may be more than
> MIB_PACKET_DROPPED + 1 packets dropped between the checks.
> 

MIB_PACKET_DROPPED is the maximum count like 0xffff.  Plus 1 means 0x10000.
It is assumed the checking should be done fast enough  to avoid overflow.  This is
just assuming one overflow has been missed.  To tell you the truth this code is
never checked for correctness.

> > +static void ksz8795_r_table(struct ksz_device *dev, int table, u16 addr,
> > +			    u64 *data)
> > +{
> > +	u16 ctrl_addr;
> > +
> > +	ctrl_addr = IND_ACC_TABLE(table | TABLE_READ) | addr;
> > +
> > +	mutex_lock(&dev->alu_mutex);
> > +	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
> > +	ksz_get(dev, REG_IND_DATA_HI, data, sizeof(u64));
> > +	mutex_unlock(&dev->alu_mutex);
> > +	*data = be64_to_cpu(*data);
> > +}
> 
> It would be a tiny bit nicer to have be64 temporary variable and use
> it; having *data change endianness at runtime is "interesting".

> > +	/* At least one valid entry in the table. */
> > +	} else {
> > +		u64 buf;
> > +		int cnt;
> > +
> > +		ksz_get(dev, REG_IND_DATA_HI, &buf, sizeof(buf));
> > +		buf = be64_to_cpu(buf);
> 
> Would it make sense to convert endianness inside ksz_get?

The ksz_get function utilizes the chip's capability to automatically
increase the register index so that their values can be retrieved in
one SPI transfer.  It is mostly used for debugging for dumping chip
registers or programming MAC address (6 bytes).  Here it is also used for
reading 8 bytes.  If you do not want to see the conversion then another
access functions like ksz_read64 and ksz_write64 will need to be implemented.

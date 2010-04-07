From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the rr tree with the net tree
Date: Wed, 7 Apr 2010 13:51:17 +1000
Message-ID: <20100407135117.1111c4a0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ondrej Zary <linux@rainbow-software.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rusty,

Today's linux-next merge of the rr tree got a conflict in
include/linux/mod_devicetable.h scripts/mod/file2alias.c between commit
8626d3b4328061f5b82b11ae1d6918a0c3602f42 ("phylib: Support phy module
autoloading") from the net tree and commits
df73f69d6a29eb5a22327009627f23c7ae4be007
("modules:isapnp-mod_devicetable.h") and a8e67afa03daca8b570115ba9b33f508cc5a9133 ("MODULE_DEVICE_TABLE(isapnp, ...) does nothing") from the rr tree.

Just overlapping additions.  I fixed it up (see below) and can carry the
fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/mod_devicetable.h
index 55f1f9c,e69d69f..0000000
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@@ -474,30 -474,11 +474,37 @@@ struct platform_device_id 
  			__attribute__((aligned(sizeof(kernel_ulong_t))));
  };
  
 +#define MDIO_MODULE_PREFIX	"mdio:"
 +
 +#define MDIO_ID_FMT "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d"
 +#define MDIO_ID_ARGS(_id) \
 +	(_id)>>31, ((_id)>>30) & 1, ((_id)>>29) & 1, ((_id)>>28) & 1,	\
 +	((_id)>>27) & 1, ((_id)>>26) & 1, ((_id)>>25) & 1, ((_id)>>24) & 1, \
 +	((_id)>>23) & 1, ((_id)>>22) & 1, ((_id)>>21) & 1, ((_id)>>20) & 1, \
 +	((_id)>>19) & 1, ((_id)>>18) & 1, ((_id)>>17) & 1, ((_id)>>16) & 1, \
 +	((_id)>>15) & 1, ((_id)>>14) & 1, ((_id)>>13) & 1, ((_id)>>12) & 1, \
 +	((_id)>>11) & 1, ((_id)>>10) & 1, ((_id)>>9) & 1, ((_id)>>8) & 1, \
 +	((_id)>>7) & 1, ((_id)>>6) & 1, ((_id)>>5) & 1, ((_id)>>4) & 1, \
 +	((_id)>>3) & 1, ((_id)>>2) & 1, ((_id)>>1) & 1, (_id) & 1
 +
 +/**
 + * struct mdio_device_id - identifies PHY devices on an MDIO/MII bus
 + * @phy_id: The result of
 + *     (mdio_read(&MII_PHYSID1) << 16 | mdio_read(&PHYSID2)) & @phy_id_mask
 + *     for this PHY type
 + * @phy_id_mask: Defines the significant bits of @phy_id.  A value of 0
 + *     is used to terminate an array of struct mdio_device_id.
 + */
 +struct mdio_device_id {
 +	__u32 phy_id;
 +	__u32 phy_id_mask;
 +};
 +
+ #define ISAPNP_ANY_ID		0xffff
+ struct isapnp_device_id {
+ 	unsigned short card_vendor, card_device;
+ 	unsigned short vendor, function;
+ 	kernel_ulong_t driver_data;	/* data private to the driver */
+ };
+ 
  #endif /* LINUX_MOD_DEVICETABLE_H */
diff --cc scripts/mod/file2alias.c
index 36a60a8,6494f5b..0000000
--- a/scripts/mod/file2alias.c
+++ b/scripts/mod/file2alias.c
@@@ -796,28 -796,19 +796,41 @@@ static int do_platform_entry(const cha
  	return 1;
  }
  
 +static int do_mdio_entry(const char *filename,
 +			 struct mdio_device_id *id, char *alias)
 +{
 +	int i;
 +
 +	alias += sprintf(alias, MDIO_MODULE_PREFIX);
 +
 +	for (i = 0; i < 32; i++) {
 +		if (!((id->phy_id_mask >> (31-i)) & 1))
 +			*(alias++) = '?';
 +		else if ((id->phy_id >> (31-i)) & 1)
 +			*(alias++) = '1';
 +		else
 +			*(alias++) = '0';
 +	}
 +
 +	/* Terminate the string */
 +	*alias = 0;
 +
 +	return 1;
 +}
 +
+ /* looks like: "pnp:dD" */
+ static int do_isapnp_entry(const char *filename,
+ 			   struct isapnp_device_id *id, char *alias)
+ {
+ 	sprintf(alias, "pnp:d%c%c%c%x%x%x%x*",
+ 		'A' + ((id->vendor >> 2) & 0x3f) - 1,
+ 		'A' + (((id->vendor & 3) << 3) | ((id->vendor >> 13) & 7)) - 1,
+ 		'A' + ((id->vendor >> 8) & 0x1f) - 1,
+ 		(id->function >> 4) & 0x0f, id->function & 0x0f,
+ 		(id->function >> 12) & 0x0f, (id->function >> 8) & 0x0f);
+ 	return 1;
+ }
+ 
  /* Ignore any prefix, eg. some architectures prepend _ */
  static inline int sym_is(const char *symbol, const char *name)
  {
@@@ -965,10 -956,10 +978,14 @@@ void handle_moddevtable(struct module *
  		do_table(symval, sym->st_size,
  			 sizeof(struct platform_device_id), "platform",
  			 do_platform_entry, mod);
 +	else if (sym_is(symname, "__mod_mdio_device_table"))
 +		do_table(symval, sym->st_size,
 +			 sizeof(struct mdio_device_id), "mdio",
 +			 do_mdio_entry, mod);
+ 	else if (sym_is(symname, "__mod_isapnp_device_table"))
+ 		do_table(symval, sym->st_size,
+ 			sizeof(struct isapnp_device_id), "isa",
+ 			do_isapnp_entry, mod);
  	free(zeros);
  }
  

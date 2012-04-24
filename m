From: "jonsmirl@gmail.com" <jonsmirl@gmail.com>
Subject: Problem with iosize in Davicom DM9000 driver
Date: Tue, 24 Apr 2012 10:54:41 -0400
Message-ID: <CAKON4OzatC3nsby3_SA_yG-TtE2-BSXE3Ojkm2DbryxTcANyQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53156 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641Ab2DXOyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 10:54:43 -0400
Received: by bkuw12 with SMTP id w12so536628bku.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 07:54:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the probe code of the DM9000 driver...

	iosize = resource_size(db->data_res);

------ iosize is the size of the resource block
static inline resource_size_t resource_size(const struct resource *res)
{
	return res->end - res->start + 1;
}

	db->data_req = request_mem_region(db->data_res->start, iosize,
					  pdev->name);

	if (db->data_req == NULL) {
		dev_err(db->dev, "cannot claim data reg area\n");
		ret = -EIO;
		goto out;
	}

	db->io_data = ioremap(db->data_res->start, iosize);

	if (db->io_data == NULL) {
		dev_err(db->dev, "failed to ioremap data reg\n");
		ret = -EINVAL;
		goto out;
	}

	/* fill in parameters for net-dev structure */
	ndev->base_addr = (unsigned long)db->io_addr;
	ndev->irq	= db->irq_res->start;

	/* ensure at least we have a default set of IO routines */
	dm9000_set_io(db, iosize);

--------------------------
---- but it is passed into this routine which is expecting byte_width.
---- luckily the default case turns it into 32b IO which works on most systems.
---- I hit this working on a system with a 16b bus

static void dm9000_set_io(struct board_info *db, int byte_width)
{
	/* use the size of the data resource to work out what IO
	 * routines we want to use
	 */

	switch (byte_width) {



-- 
Jon Smirl
jonsmirl@gmail.com

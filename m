From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/2] be2net: Need a delay before processing CQE
 after 2nd mbox register write
Date: Wed, 8 Jan 2014 09:32:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D454FBA@AcuExch.aculab.com>
References: <4b4fd4cb-9d23-4900-a20c-f2c2bef70849@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: 'Somnath Kotur' <somnath.kotur@emulex.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55546 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753960AbaAHJeC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 04:34:02 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24201-04 for <netdev@vger.kernel.org>;
 Wed,  8 Jan 2014 09:34:00 +0000 (GMT)
In-Reply-To: <4b4fd4cb-9d23-4900-a20c-f2c2bef70849@CMEXHTCAS2.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Somnath Kotur
> Due to Host platform synchronization issues between the mbox RDY bit polled
> status and the completion of the DMA for the CQE, it is preferable that the
> Host always wait for the RDY bit to transition to 1 after the 2nd mbox register
> write and always follow that with a short wait for the valid bit in the CQE,
> before processing the CQE.

While I don't doubt that a delay(1) fixes the problem it doesn't
seem an ideal solution.
I've not looked at what the code is doing (or how often it does it)
but either delay(1) is far, far longer than is necessary or it might
not be long enough and some kind of retry loop is required.

It might even be that the driver is just missing a memory barrier.

	David

> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
> index 94c35c8..78560f2 100644
> --- a/drivers/net/ethernet/emulex/benet/be_cmds.c
> +++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
> @@ -502,6 +502,9 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
>  	if (status != 0)
>  		return status;
> 
> +	/* Need a delay before processing CQE after 2nd mbox register write */
> +	udelay(1);
> +
>  	/* A cq entry has been made now */
>  	if (be_mcc_compl_is_new(compl)) {
>  		status = be_mcc_compl_process(adapter, &mbox->compl);
> --
> 1.6.0.2

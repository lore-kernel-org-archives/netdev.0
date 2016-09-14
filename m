From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [RFC 07/11] Add support for memory registeration verbs
Date: Wed, 14 Sep 2016 12:25:30 +0300
Message-ID: <4b392963-c14c-d793-147a-67b08e97ee06@grimberg.me>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-8-git-send-email-Ram.Amrani@qlogic.com>
 <7fa4a9b8-7cb1-0f83-d6e5-1055ae59bce4@grimberg.me>
 <BLUPR0701MB192207820BA5CF59A835181088F10@BLUPR0701MB1922.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
        "Michal.Kalderon@qlogic.com" <Michal.Kalderon@qlogic.com>,
        "rajesh.borundia@qlogic.com" <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kalderon, Michal" <Michal.Kalderon@cavium.com>,
        Ram Amrani <Ram.Amrani@qlogic.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35425 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751567AbcINJZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 05:25:35 -0400
In-Reply-To: <BLUPR0701MB192207820BA5CF59A835181088F10@BLUPR0701MB1922.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>> +struct qedr_mr *__qedr_alloc_mr(struct ib_pd *ibpd, int
>>> +max_page_list_len) {
>>> +	struct qedr_pd *pd = get_qedr_pd(ibpd);
>>> +	struct qedr_dev *dev = get_qedr_dev(ibpd->device);
>>> +	struct qedr_mr *mr;
>>> +	int rc = -ENOMEM;
>>> +
>>> +	DP_VERBOSE(dev, QEDR_MSG_MR,
>>> +		   "qedr_alloc_frmr pd = %d max_page_list_len= %d\n", pd-
>>> pd_id,
>>> +		   max_page_list_len);
>>> +
>>> +	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
>>> +	if (!mr)
>>> +		return ERR_PTR(rc);
>>> +
>>> +	mr->dev = dev;
>>> +	mr->type = QEDR_MR_FRMR;
>>> +
>>> +	rc = init_mr_info(dev, &mr->info, max_page_list_len, 1);
>>> +	if (rc)
>>> +		goto err0;
>>> +
>>> +	rc = dev->ops->rdma_alloc_tid(dev->rdma_ctx, &mr->hw_mr.itid);
>>> +	if (rc) {
>>> +		DP_ERR(dev, "roce alloc tid returned an error %d\n", rc);
>>> +		goto err0;
>>> +	}
>>> +
>>> +	/* Index only, 18 bit long, lkey = itid << 8 | key */
>>> +	mr->hw_mr.tid_type = QED_RDMA_TID_FMR;
>>> +	mr->hw_mr.key = 0;
>>> +	mr->hw_mr.pd = pd->pd_id;
>>
>> Do you have a real MR<->PD association in HW? If so, can you point me to the
>> code that binds it? If not, any reason not to expose the local_dma_lkey?
>>
> Yes, we send the pd id to the FW in function qed_rdma_register_tid.

Right, thanks.

> In any case, if we didn't have the association in HW
> Wouldn't the local_dma_lkey be relevant only to dma_mr ? ( code snippet above refers to FMR)

I was just sticking to a location in the code where you associate
MR<->PD...

The local_dma_lkey is a special key that spans the entire memory space
and unlike the notorious dma_mr, its not associated with a PD.

See the code in ib_alloc_pd(), if the device does not support a single
device local dma lkey, the core allocates a dma mr associated with
the pd. If your device has such a key, you can save a dma mr allocation
for each pd in the system.

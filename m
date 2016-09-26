From: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 08/16] IB/pvrdma: Add device command support
Date: Mon, 26 Sep 2016 11:06:06 -0700
Message-ID: <3697a394-4bb0-b745-1ae2-5e0583a53a96@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <47e16986707ddbe0ffa15795ef9ae60d15bdd728.1474759181.git.aditr@vmware.com>
 <20160926071601.GA6352@yuval-lap.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160926071601.GA6352-Hxa29pjIrERMGUUWBy6pNA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 26, 2016 at 00:16:01AM -0700, Yuval Shaia wrote:
> Minor question/suggestion inline.
> (sorry for missing it till now).
> 
> Yuval

<...>

> > +int
> > +pvrdma_cmd_post(struct pvrdma_dev *dev, union pvrdma_cmd_req *req,
> > +		union pvrdma_cmd_resp *resp, unsigned resp_code)
> > +{
> > +	int err;
> > +
> > +	dev_dbg(&dev->pdev->dev, "post request to device\n");
> > +
> > +	/* Serializiation */
> > +	down(&dev->cmd_sema);
> > +
> > +	BUILD_BUG_ON(sizeof(union pvrdma_cmd_req) !=
> > +		     sizeof(struct pvrdma_cmd_modify_qp));
> > +
> > +	spin_lock(&dev->cmd_lock);
> > +	memcpy(dev->cmd_slot, req, sizeof(*req));
> > +	spin_unlock(&dev->cmd_lock);
> > +
> > +	init_completion(&dev->cmd_done);
> > +	pvrdma_write_reg(dev, PVRDMA_REG_REQUEST, 0);
> > +
> > +	/* Make sure the request is written before reading status. */
> > +	mb();
> > +
> > +	err = pvrdma_read_reg(dev, PVRDMA_REG_ERR);
> > +	if (err == 0) {
> > +		if (resp != NULL)
> > +			err = pvrdma_cmd_recv(dev, resp, resp_code);
> > +	} else {
> > +		dev_warn(&dev->pdev->dev, "failed to write request %d\n", err);
> > +	}
> 
> Please note that callers checks if err<0  while here err!=0 considered as
> error.
> Looking at similar code in pvrdma_pci_probe i can see that function
> "translates" this error to -EINVAL. Suggesting to do the same here
> (although -EINVAL is not a good choice, if device can be more friendly with
> the return code then we can propagate it up or just print a suitable error
> i.e. EAGAIN or ENOMEM otherwise EFAULT should be sufficient).
>

Thanks for pointing this out.
I dont think we return a positive error from the error register. So the
(err == 0) should be (err >= 0). Also, I'll set the err to -EFAULT if
read_reg fails (based on your feedback on the other patch).
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

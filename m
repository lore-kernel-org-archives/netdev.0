From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_en: fix off by one in error handling
Date: Wed, 14 Sep 2016 18:08:44 +0200 (CEST)
Message-ID: <alpine.LFD.2.20.1609141757040.1730@schleppi>
References: <alpine.LFD.2.20.1609141305360.1727@schleppi> <df5834ee-00c2-3f18-ae83-8bb06b6c675b@gmail.com> <alpine.LFD.2.20.1609141548390.11022@schleppi> <b2197c51-57a9-ab01-e940-9850a39484d6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38802 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1761966AbcINQIw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 12:08:52 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8EG8M6k014986
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 12:08:51 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25exsmbwc7-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 12:08:51 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
        Wed, 14 Sep 2016 17:08:49 +0100
In-Reply-To: <b2197c51-57a9-ab01-e940-9850a39484d6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Sep 2016, Tariq Toukan wrote:
> On 14/09/2016 4:53 PM, Sebastian Ott wrote:
> > On Wed, 14 Sep 2016, Tariq Toukan wrote:
> > > On 14/09/2016 2:09 PM, Sebastian Ott wrote:
> > > > If an error occurs in mlx4_init_eq_table the index used in the
> > > > err_out_unmap label is one too big which results in a panic in
> > > > mlx4_free_eq. This patch fixes the index in the error path.
> > > You are right, but your change below does not cover all cases.
> > > The full solution looks like this:
> > >
> > > @@ -1260,7 +1260,7 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
> > >                                               eq);
> > >                  }
> > >                  if (err)
> > > -                       goto err_out_unmap;
> > > +                       goto err_out_unmap_excluded;
> > In this case a call to mlx4_create_eq failed. Do you really have to call
> > mlx4_free_eq for this index again?
>
> We agree on this part, that's why here we should goto the _excluded_ label.
> For all other parts, we should not exclude the eq in the highest index, and
> thus we goto the _non_excluded_ label.

But that's exactly what the original patch does. If the failure is within
the for loop at index i, we do the cleanup starting at index i-1. If the
failure is after the for loop then i == dev->caps.num_comp_vectors + 1
and we do the cleanup starting at index i == dev->caps.num_comp_vectors.

In the latter case your patch would have an out of bounds array access.

Regards,
Sebastian

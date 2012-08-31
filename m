From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Possible issue with Mellanox be2net/port handling
Date: Fri, 31 Aug 2012 09:25:03 -0300
Message-ID: <5040AD1F.9080702@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161Ab2HaMZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 08:25:05 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7VCP4CV028476
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2012 08:25:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Commit 
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=4c41b3673759d096106e68bce586f103c51d4119 
inserted changes like:

@@ -361,7 +361,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
         int err;
         struct mlx4_priv *priv = mlx4_priv(dev);

-       s_steer = &mlx4_priv(dev)->steer[0];
+       s_steer = &mlx4_priv(dev)->steer[port - 1];

         mutex_lock(&priv->mcg_table.mutex);

But I fear we missed one part of the deal. Concept patch:

@@ -365,7 +365,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,

         mutex_lock(&priv->mcg_table.mutex);

-       if (get_promisc_qp(dev, 0, steer, qpn)) {
+       if (get_promisc_qp(dev, port - 1, steer, qpn)) {
                 err = 0;  /* Noting to do, already exists */
                 goto out_mutex;
         }

Because:

static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
               enum mlx4_steer_type steer, u32 qpn)
{
...
A)  s_steer = &mlx4_priv(dev)->steer[port - 1];

     mutex_lock(&priv->mcg_table.mutex);

     if (get_promisc_qp(dev, 0, steer, qpn)) {
         err = 0;  /* Noting to do, already exists */
         goto out_mutex;
     }
...
     /* add the new qpn to list of promisc qps */
C)  list_add_tail(&pqp->list, &s_steer->promisc_qps[steer]);
...
}

static struct mlx4_promisc_qp *get_promisc_qp(struct mlx4_dev *dev, u8 
pf_num,
                           enum mlx4_steer_type steer,
                           u32 qpn)
{
B)  struct mlx4_steer *s_steer = &mlx4_priv(dev)->steer[pf_num];
     struct mlx4_promisc_qp *pqp;

     list_for_each_entry(pqp, &s_steer->promisc_qps[steer], list) {
         if (pqp->qpn == qpn)
             return pqp;
     }
     /* not found */
     return NULL;
}

As far as I can understand, we are changing a list for a port and 
checking for duplicates on the other list. Points marked as A, B and C 
for highlighting. Am I missing something? What do you think?

FWIW, this call get_promisc_qp(dev, 0, ...) happens in other places too.

Thank you,
Marcelo.

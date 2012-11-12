From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: question about RT_TABLE_MAX
Date: Mon, 12 Nov 2012 17:51:35 +0300
Message-ID: <20121112145135.GA32199@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43741 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628Ab2KLOvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 09:51:45 -0500
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id qACEpipE016636
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2012 14:51:45 GMT
Received: from acsmt358.oracle.com (acsmt358.oracle.com [141.146.40.158])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id qACEphev010612
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2012 14:51:44 GMT
Received: from abhmt105.oracle.com (abhmt105.oracle.com [141.146.116.57])
	by acsmt358.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id qACEphiZ015685
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2012 08:51:43 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RT_TABLE_MAX is 0xFFFFFFFF.  It's always compared against an unsigned
int so the checks against it don't test anything.

net/decnet/dn_table.c
   828  struct dn_fib_table *dn_fib_get_table(u32 n, int create)
   829  {
   830          struct dn_fib_table *t;
   831          struct hlist_node *node;
   832          unsigned int h;
   833  
   834          if (n < RT_TABLE_MIN)
   835                  return NULL;
   836  
   837          if (n > RT_TABLE_MAX)
                    ^^^^^^^^^^^^^^^^
Never true.
   838                  return NULL;

net/decnet/dn_table.c
   874  struct dn_fib_table *dn_fib_empty_table(void)
   875  {
   876          u32 id;
   877  
   878          for(id = RT_TABLE_MIN; id <= RT_TABLE_MAX; id++)
                                       ^^^^^^^^^^^^^^^^^^
Always true.
   879                  if (dn_fib_get_table(id, 0) == NULL)
   880                          return dn_fib_get_table(id, 1);
   881          return NULL;
   882  }

net/ipv4/fib_rules.c
   122  static struct fib_table *fib_empty_table(struct net *net)
   123  {
   124          u32 id;
   125  
   126          for (id = 1; id <= RT_TABLE_MAX; id++)
                             ^^^^^^^^^^^^^^^^^^
Always true.
   127                  if (fib_get_table(net, id) == NULL)
   128                          return fib_new_table(net, id);
   129          return NULL;
   130  }

Maybe it should be id < RT_TABLE_MAX?

regards,
dan carpenter

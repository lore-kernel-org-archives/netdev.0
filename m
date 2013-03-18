From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: question about klen in move_addr_to_user()
Date: Mon, 18 Mar 2013 13:10:07 +0300
Message-ID: <20130318101007.GO9189@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50368 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355Ab3CRKKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 06:10:18 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r2IAAHx9032514
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 10:10:17 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r2IAAGQa010949
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 10:10:16 GMT
Received: from abhmt104.oracle.com (abhmt104.oracle.com [141.146.116.56])
	by acsmt357.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id r2IAAGxO003401
	for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 05:10:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch complains that about a potential buffer overflow in
move_add_to_user()

net/socket.c
   212  static int move_addr_to_user(struct sockaddr_storage *kaddr, int klen,
   213                               void __user *uaddr, int __user *ulen)
   214  {
   215          int err;
   216          int len;
   217  
   218          err = get_user(len, ulen);
   219          if (err)
   220                  return err;
   221          if (len > klen)
   222                  len = klen;
   223          if (len < 0 || len > sizeof(struct sockaddr_storage))
   224                  return -EINVAL;
   225          if (len) {
   226                  if (audit_sockaddr(klen, kaddr))
                                           ^^^^
Smatch complains that although "len" is capped here, "klen" hasn't
necessarily been.  If "klen" is more than 128 bytes it leads to
memory corruption.

   227                          return -ENOMEM;
   228                  if (copy_to_user(uaddr, kaddr, len))
   229                          return -EFAULT;
   230          }

The call tree is this:

__sys_recvmsg() gets the msg->msg_namelen from the user.

Normally the network protocols set msg->msg_namelen in their
->recvmsg() function but some don't like caif_seqpkt_recvmsg() and
recv_msg() for tipc.

regards,
dan carpenter

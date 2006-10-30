From: Paul Moore <paul.moore@hp.com>
Subject: Re: [patch 1/1] NetLabel: protect the CIPSOv4 socket option from
 setsockopt()
Date: Mon, 30 Oct 2006 15:58:43 -0500
Message-ID: <45466783.6020301@hp.com>
References: <20061030180331.404950000@hp.com>	 <20061030180801.641867000@hp.com> <1162240306.20103.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@redhat.com,
	sds@epoch.ncsc.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:53642 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1161460AbWJ3U6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 15:58:47 -0500
To: Eric Paris <eparis@redhat.com>
In-Reply-To: <1162240306.20103.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Paris wrote:
> On Mon, 2006-10-30 at 13:03 -0500, paul.moore@hp.com wrote:
> 
>>plain text document attachment (netlabel-sockopts)
>>From: Paul Moore <paul.moore@hp.com>
>>
>>This patch makes two changes to protect applications from either removing or
>>tampering with the CIPSOv4 IP option on a socket.  The first is the requirement
>>that applications have the CAP_NET_RAW capability to set an IPOPT_CIPSO option
>>on a socket; this prevents untrusted applications from setting their own
>>CIPSOv4 security attributes on the packets they send.  The second change is to
>>SELinux and it prevents applications from setting any IPv4 options when there
>>is an IPOPT_CIPSO option already present on the socket; this prevents
>>applications from removing CIPSOv4 security attributes from the packets they
>>send.
> 
> 
>>--- net-2.6_sockopt.orig/security/selinux/ss/services.c
>>+++ net-2.6_sockopt/security/selinux/ss/services.c
>>@@ -2682,4 +2682,41 @@ u32 selinux_netlbl_socket_getpeersec_dgr
>> 
>> 	return peer_sid;
>> }
>>+
>>+/**
>>+ * selinux_netlbl_socket_setsockopt - Do not allow users to remove a NetLabel
>>+ * @sock: the socket
>>+ * @level: the socket level or protocol
>>+ * @optname: the socket option name
>>+ *
>>+ * Description:
>>+ * Check the setsockopt() call and if the user is trying to replace the IP
>>+ * options on a socket and a NetLabel is in place for the socket deny the
>>+ * access; otherwise allow the access.  Returns zero when the access is
>>+ * allowed, -EACCES when denied, and other negative values on error.
>>+ *
>>+ */
>>+int selinux_netlbl_socket_setsockopt(struct socket *sock,
>>+				     int level,
>>+				     int optname)
>>+{
>>+	int rc = 0;
>>+	struct inode *inode = SOCK_INODE(sock);
>>+	struct sk_security_struct *sksec = sock->sk->sk_security;
>>+	struct inode_security_struct *isec = inode->i_security;
>>+	struct netlbl_lsm_secattr secattr;
>>+
>>+	mutex_lock(&isec->lock);
>>+	if (level == IPPROTO_IP && optname == IP_OPTIONS &&
>>+	    sksec->nlbl_state == NLBL_LABELED) {
>>+		netlbl_secattr_init(&secattr);
>>+		rc = netlbl_socket_getattr(sock, &secattr);
>>+		if (rc == 0 && (secattr.cache || secattr.mls_lvl_vld))
>>+			rc = -EACCES;
>>+		netlbl_secattr_destroy(&secattr);
>>+	}
>>+	mutex_unlock(&isec->lock);
>>+
>>+	return rc;
>>+}
>> #endif /* CONFIG_NETLABEL */
> 
> I probably should have ask this a while back but both here and in
> selinux_netlbl_socket_setsid() you are taking the isec->lock.  As I
> originally understood the isec->lock it was just supposed to just
> prevent multiple tasks from initializing the isec information
> simultaneously while the isec information could be in an inconsistent
> state.  After isec->initialized was set we didn't use the lock any more
> (as typically the only change inside the isec was the ->sid which
> couldn't even be 'in the middle').  I'm wondering what you are hoping to
> protect taking this lock.  It doesn't seem like it would hurt anything,
> but i'd like to hear what you see it's purpose as being...   (Then again
> it's just as unlikely that I understood what it was being used for
> pre-netlabel)

Fair question.  It was discussed a while back on either the SELinux or LSPP
mailing list, I don't have a link handy but I'm sure you could find it with your
favorite search engine (it was discussed back when it was a semaphore); I might
be wrong but I think it was Stephen Smalley that suggested using the isec
semaphore/mutex.  Basically, inode_security_struct mutex also protects the
sk_security_struct->nlbl_state field.  You will see some cases where the
nlbl_state field is set/checked without holding the mutex but in those cases
only one thread should have access to the sock.

Perhaps at some point it would make sense to protect this with some other
locking mechanism (rcu might make the most sense) but considering the stage that
2.6.19 is at right now I think we should probably leave it alone right now.

-- 
paul moore
linux security @ hp

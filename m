From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Thu, 22 Jul 2010 13:41:38 +0900
Message-ID: <201007220441.o6M4fcmC093106@www262.sakura.ne.jp>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp> <20100721.114509.37203355.davem@davemloft.net> <201007220338.o6M3citW076383@www262.sakura.ne.jp> <20100721.210636.197931242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:54438 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab0GVEll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 00:41:41 -0400
In-Reply-To: <20100721.210636.197931242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Your analysis is wrong, and what Tomoyo is doing is so fundamentally
> different than what the existing SELINUX hooks do.
> 
> The existing LSM hooks do not break BSD socket behavior.  Do you know
> why?  Because someone who understood all of this spent a great deal
> of time carefully designing them.
> 
> The existing hooks do not drop packets on recvmsg() when a security
> check does not pass, they signal the error long before the socket
> receive queue is even looked at.  It is just like seeing a -EFAULT,
> -ENFILE, or similar error.
> 
> Checks are always made _BEFORE_ major state changes are made to the
> socket.

Excuse me, below check is made inside recvmsg() and may return error if
SELinux's policy has changed after the select() said "ready" and before
security_socket_recvmsg() is called. No?

int avc_has_perm_noaudit(u32 ssid, u32 tsid,
                         u16 tclass, u32 requested,
                         unsigned flags,
                         struct av_decision *in_avd)
{
        struct avc_node *node;
        struct av_decision avd_entry, *avd;
        int rc = 0;
        u32 denied;

        BUG_ON(!requested);

        rcu_read_lock();

        node = avc_lookup(ssid, tsid, tclass);
        if (!node) {
                rcu_read_unlock();

                if (in_avd)
                        avd = in_avd;
                else
                        avd = &avd_entry;

                security_compute_av(ssid, tsid, tclass, avd);
                rcu_read_lock();
                node = avc_insert(ssid, tsid, tclass, avd);
        } else {
                if (in_avd)
                        memcpy(in_avd, &node->ae.avd, sizeof(*in_avd));
                avd = &node->ae.avd;
        }

        denied = requested & ~(avd->allowed);

        if (denied) {
                if (flags & AVC_STRICT)
                        rc = -EACCES;
                else if (!selinux_enforcing || (avd->flags & AVD_FLAGS_PERMISSIVE))
                        avc_update_node(AVC_CALLBACK_GRANT, requested, ssid,
                                        tsid, tclass, avd->seqno);
                else
                        rc = -EACCES;
        }

        rcu_read_unlock();
        return rc;
}

int avc_has_perm(u32 ssid, u32 tsid, u16 tclass,
                 u32 requested, struct common_audit_data *auditdata)
{
        struct av_decision avd;
        int rc;

        rc = avc_has_perm_noaudit(ssid, tsid, tclass, requested, 0, &avd);
        avc_audit(ssid, tsid, tclass, requested, &avd, rc, auditdata);
        return rc;
}

static int socket_has_perm(struct task_struct *task, struct socket *sock,
                           u32 perms)
{
        struct inode_security_struct *isec;
        struct common_audit_data ad;
        u32 sid;
        int err = 0;

        isec = SOCK_INODE(sock)->i_security;

        if (isec->sid == SECINITSID_KERNEL)
                goto out;
        sid = task_sid(task);

        COMMON_AUDIT_DATA_INIT(&ad, NET);
        ad.u.net.sk = sock->sk;
        err = avc_has_perm(sid, isec->sid, isec->sclass, perms, &ad);

out:
        return err;
}

static int selinux_socket_recvmsg(struct socket *sock, struct msghdr *msg,
                                  int size, int flags)
{
        return socket_has_perm(current, sock, SOCKET__READ);
}

static struct security_operations selinux_ops = {
(...snipped...)
	.socket_recvmsg =               selinux_socket_recvmsg,
(...snipped...)
};

Are you saying that selinux_socket_recvmsg() always returns 0?

> That is critically important, and it's what you seem to fail to see.
> 
> The hooks you propose _LOSE_ information.  So even if another process
> has the 'fd' for a socket, and they would be allowed to receive the
> packet by LSM checks, the post hook does not allow that to happen
> because the failing 'fd' just frees up the packet and loses it
> forever.
> 
> The existing hooks signal before we pull the new connection out of the
> accept queue during accept(), therefore avoiding the illegal situation
> your post ->accept() hook would create since there is absolutely no
> way (and there should not be a way) to push a connection back into the
> sock accept queue after we've taken it from the protocol layer.
> 
> And again here, the proposed hooks _LOSE_ information.  The accepted
> connection is lost forever, another process with valid security
> credentials cannot accept the connection.  It is completely gone.
> 
> And I'm not even going to entertain adding facilities to allow pushing
> things back into the socket state after they've been removed for
> inspection.
> 
> I think we've been through this issue enough times that we have covered
> the issues in their entirety, and nothing you have written convinces
> me that my position is wrong and that it is valid to put the Tomoyo
> post-recvmsg and post-accept hooks into the tree.
> 
> Sorry, but I'm not applying your patches, they are fundamentally flawed
> unlike the existing hooks.

Did the idea described in previous mail _LOSE_ information?
I made the udp_recvmsg() to force MSG_PEEK so that the message will not be
removed from the queue if security_socket_post_recvmsg() returned error code
and remove the message from the queue only if security_socket_post_recvmsg()
returned 0 and the caller did not pass MSG_PEEK.

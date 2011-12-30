From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: WTF is going with sock->file "allocation" by iscsi_target_login.c?
Date: Fri, 30 Dec 2011 01:34:11 +0000
Message-ID: <20111230013411.GT23916@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, open-iscsi@googlegroups.com,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In iscsi_target_setup_login_socket()
        /*
         * The SCTP stack needs struct socket->file.
         */
        if ((np->np_network_transport == ISCSI_SCTP_TCP) ||
            (np->np_network_transport == ISCSI_SCTP_UDP)) {
                if (!sock->file) {
                        sock->file = kzalloc(sizeof(struct file), GFP_KERNEL);
and similar bit slightly below are utterly bogus.  In the best case the comment
is BS and SCTP actually doesn't give a damn about having non-NULL sock->file.
Assuming that this Fine Piece Of Software actually manages to deal with
all codepaths that might kill that sock, that is.

In the worst case, we end up leaking stuff or passing that object to something
that expect real struct file *.  In which case we are well and truly screwed.

Could somebody familiar with the code in question (iscsi and sctp) explain
what the hell is going on?

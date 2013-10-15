From: Olaf Hering <olaf@aepfle.de>
Subject: getting lldp DCB_CMD_IEEE_GET after DCB_CMD_GCAP fails
Date: Tue, 15 Oct 2013 18:18:39 +0200
Message-ID: <20131015161838.GA10478@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:33977 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759113Ab3JOQSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 12:18:43 -0400
Received: from probook.site
	(dslb-088-074-056-021.pools.arcor-ip.net [88.74.56.21])
	by smtp.strato.de (RZmta 32.6 DYNA|AUTH)
	with (TLSv1.0:DHE-RSA-AES256-SHA encrypted) ESMTPSA id e0125cp9FFgf27
	for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 18:18:39 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If this list is the wrong place, please point me to the right direction.


In the example code below the part which grabs DCB_CMD_IEEE_GET fails,
unless the "hack" part is executed. What I see inside the kernel is that
__netlink_dump_start gets to the err=-EBUSY case because nlk->cb is
still set. The nl_ack_handler is executed, an "empty" error is returned.
I have compared my code with open-lldp-0.9.46/test/nltest.c and did not
spot the difference.


Is the code below supposed to work anyway? Thanks for any help.


Olaf


/* cc -lnl lldptest.c -o lldptest */
#include <stdio.h>
#include <netlink/msg.h>
#include <linux/dcbnl.h>

static int nl_dump_valid(struct nl_msg *msg, void *p)
{
	struct nlmsghdr *nlh = p;
	nlh = nlmsg_hdr(msg);
	printf("%s: %x\n", __func__, nlh->nlmsg_len);
	return NL_OK;
}

static int nl_ack_handler(struct nl_msg *msg, void *arg)
{
	arg = msg;
	printf("%s: %p\n", __func__, arg);
	return NL_STOP;
}

static int nl_error_handler(struct sockaddr_nl *sender, struct nlmsgerr *err, void *arg)
{
	char *s = arg;
	printf("%s: %p %s %x\n", __func__, sender, s, err->error);
	return NL_STOP;
}

int main(int argc, char *argv[])
{
	struct nl_handle *nl_handle;
	struct nl_cb *nl_cb, *tmp_cb;
	struct nl_msg *msg;
	struct nlattr *nla;
	struct dcbmsg dcb = {.dcb_family = AF_UNSPEC, };
	char *ifname;
	int hack;
	int protocol = 0;
	int ret = 1;

	if (argc < 2) {
		printf("Usage: %s <ifname> [hack]\n", argv[0]);
		goto out;
	}
	ifname = argv[1];
	hack = !!argv[2];

	nl_cb = nl_cb_alloc(NL_CB_DEFAULT);
	if (!nl_cb) {
		perror("nl_cb_alloc");
		goto out;
	}
	nl_handle = nl_handle_alloc_cb(nl_cb);
	if (nl_connect(nl_handle, protocol) < 0) {
		perror("nl_connect");
		goto out;
	}

	tmp_cb = nl_cb_clone(nl_cb);
	dcb.cmd = DCB_CMD_GCAP;
	nl_cb_err(tmp_cb, NL_CB_CUSTOM, nl_error_handler, "DCB_CMD_GCAP");
	nl_cb_set(tmp_cb, NL_CB_ACK, NL_CB_CUSTOM, nl_ack_handler, NULL);
	nl_cb_set(tmp_cb, NL_CB_VALID, NL_CB_CUSTOM, nl_dump_valid, NULL);

	msg = nlmsg_alloc_simple(RTM_GETDCB, NLM_F_REQUEST);
	if (!msg) {
		perror("nlmsg_alloc_simple");
		goto out;
	}
	if (nlmsg_append(msg, &dcb, sizeof(dcb), NLMSG_ALIGNTO) < 0) {
		perror("nlmsg_append");
		goto out;
	}

	NLA_PUT_STRING(msg, DCB_ATTR_IFNAME, ifname);
	nla = nla_nest_start(msg, DCB_ATTR_CAP);
	NLA_PUT_FLAG(msg, DCB_CAP_ATTR_ALL);
	nla_nest_end(msg, nla);

	if (nl_send_auto_complete(nl_handle, msg) < 0) {
		perror("nl_send_auto_complete");
		goto out;
	}

	if ((nl_recvmsgs(nl_handle, tmp_cb)) < 0) {
		perror("nl_recvmsgs");
		goto out;
	}

	nl_cb_put(tmp_cb);
	nlmsg_free(msg);

	if (hack) {
		nl_close(nl_handle);
		nl_handle = nl_handle_alloc_cb(nl_cb);
		if (nl_connect(nl_handle, protocol) < 0) {
			perror("nl_connect");
			goto out;
		}
	}

	tmp_cb = nl_cb_clone(nl_cb);
	dcb.cmd = DCB_CMD_IEEE_GET;
	nl_cb_err(tmp_cb, NL_CB_CUSTOM, nl_error_handler, "DCB_CMD_IEEE_GET");
	nl_cb_set(tmp_cb, NL_CB_ACK, NL_CB_CUSTOM, nl_ack_handler, NULL);
	nl_cb_set(tmp_cb, NL_CB_VALID, NL_CB_CUSTOM, nl_dump_valid, NULL);

	msg = nlmsg_alloc_simple(RTM_GETDCB, NLM_F_REQUEST);
	if (!msg) {
		perror("nlmsg_alloc_simple");
		goto out;
	}
	if (nlmsg_append(msg, &dcb, sizeof(dcb), NLMSG_ALIGNTO) < 0) {
		perror("nlmsg_append");
		goto out;
	}

	NLA_PUT_STRING(msg, DCB_ATTR_IFNAME, ifname);
	if (nl_send_auto_complete(nl_handle, msg) < 0) {
		perror("nl_send_auto_complete");
		goto out;
	}

	if ((nl_recvmsgs(nl_handle, tmp_cb)) < 0) {
		perror("nl_recvmsgs");
		goto out;
	}

	nl_cb_put(tmp_cb);
	nlmsg_free(msg);

	ret = 0;

      nla_put_failure:
      out:
	return ret;
}

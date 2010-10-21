From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: TIPC security issues
Date: Thu, 21 Oct 2010 19:45:52 -0400
Message-ID: <1287704752.11051.79.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: security@kernel.org, netdev@vger.kernel.org
To: jon.maloy@ericsson.com, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:53984 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab0JUXqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 19:46:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tipc_msg_build() function in net/tipc/msg.c is written in such a way
as to create a highly exploitable kernel heap overflow that would allow
a local user to escalate privileges to root by issuing maliciously
crafted sendmsg() calls.  At a minimum, the following issues should be
fixed:

1. The tipc_msg_calc_data_size() function is almost totally broken.  It
sums together size_t values (iov_lens), but returns an integer.  Two
things can go wrong - the total value can wrap around, or on 64-bit
platforms, iov_len values greater than UINT_MAX will be truncated.

2. The comparison of dsz to TIPC_MAX_USER_MSG_SIZE is signed, so
negative (large unsigned) values will pass this check.

3. The comparison of sz to max_size is also signed.

As a result of these issues, it's possible to cause the allocation of a
small heap buffer and the subsequent copying of a carefully controlled
larger amount of data into that buffer.

I haven't found a Linux distribution that defines a module alias for
TIPC (even though most compile it as a module), so an administrator will
have had to explicitly load the TIPC module for a system to be
vulnerable.

-Dan


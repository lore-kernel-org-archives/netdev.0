From: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Subject: [PATCH 0/2] Phonet: Implement Pipe Controller to support Nokia Slim Modems
Date: Fri, 24 Sep 2010 17:53:14 +0530
Message-ID: <1285330996-27076-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <STEricsson_nomadik_linux@list.st.com>,
	<sudeep.divakaran@stericsson.com>,
	<gulshan.karmani@stericsson.com>,
	Kumar Sanghvi <kumar.sanghvi@stericsson.com>
To: <remi.denis-courmont@nokia.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:44200 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017Ab0IXMxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 08:53:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>

This patch implements the Pipe Controller functionality in Phonet stack to
support Nokia Modems like WG2.5 which do not have Pipe Controller in them.

Abbreviation:
APE: Application Processing Engine running Linux Kernel.
Modem is a separate entity attached to the APE.

With the current Phonet stack, to send Pipe data (example TCP/IP data over
GPRS), it is assumed that there is some type of Pipe Controller present either
in Modem or on APE user-space.

Many Nokia Modems implement the Pipe controller inside them.
HOwever, the Nokia Slim Modem WG2.5, the one in ST-Ericsson U8500 platform,
does not implement the Pipe Controller.
So, it is expected that APE running Linux implement the Pipe controller.

Now, PN_DEV_HOST (0x00) is normally the address of modem, so Phonet stack sends
out Pipe data by default on 0x00.
However, the Nokia Slim Modem WG2.5 expects that any data directed to it from
App processing engine should have dst_dev = 0x60 in Phonet header.

On APE side, Pipe controller can be implemented either in user-space or at
Phonet stack level.

1. Pipe controller at User-space level
---------------------------------------
There are 3 cases now:

	Case 1: net_device carrying phonet traffic on APE has device address
	= 0x6c and user-space specifies destination as 0x00.
	---------------------------------------------------------------------

	Nokia Slim modem WG2.5 simply gets reset for MCE related messages which
	has dest_dev as something other than 0x60 in Phonet header.
	Further, the modem does not process Pipe messages which has dest_dev as
	something other than 0x60 in Phonet header, and simply echoes the
	message back.

	Case 2: net_device carrying phonet traffic on APE has device address
	= 0x6c and user-space specifies destination as 0x60.
	---------------------------------------------------------------------

	Things work fine here.
	The GPRS device gets created also and IP address is also obtained from
	modem.
	However, problem comes when its time for sending PIPE_DATA.
	Phonet stack will by default send PIPE_DATA to destination with dst_dev
	= 0x00 and dst_obj = 0x00 in pipe_skb_send. So, modem, as indicated in
	case above, will not process the Pipe data message which has dest_dev
	as something other than 0x60 in Phonet header, and simply echoes the
	message back. So, the GPRS device user never gets a correct response.

	Case 3: net_device carrying phonet traffic on APE has device address
	= 0x00 and user-space specified destination as 0x60.
	---------------------------------------------------------------------

	Things work fine here also.
	The GPRS device gets created also and IP address is also obtained from
	modem.
	However, again problem comes when its time for sending PIPE_DATA.
	Since, Phonet stack will send PIPE_DATA to dest_dev = 0x00 and dest_obj
	= 0x00, and since APE net-device also has address = 0x00, this message
	will get looped-back.
	So, some user-space app OR user-space Pipe handler has to take this
	data, fill in correct dst_dev (0x60) and send it to modem.
	As a result, the traffic essentially traverses two times via the Phonet
	stack:
		1st. via pipe_skb_send which will send data to 0x00 - which will
	 	     get looped back.
		2nd. via user-space pipe handler which again sends this data to
		     modem via phonet stack.

	Again, in the receive path, the return traffic will first go to pipe
	handler in user-space and then it will go to gprs0 device.

2. Pipe Controller at Phonet stack
----------------------------------

Implementing Pipe controller at Phonet stack resolves the problem of GPRS data
traversing two times the Phonet stack in Case 3 above.
Further, the pipe-creation and related Pipe handling will be transparent to
user-space.

This patch implements the Pipe controller logic in Phonet stack.
The implementation is derived from 'Nokia Wireless Modem API -
WirelessModem_API_user_guide.pdf' document depicting the sequence for
establishing data connection.

The patch adds a Kconfig option to Phonet stack allowing users to
enable/disable Pipe controller functionality in Phonet stack.
Users can enable this option for Nokia Slim modems which do not have Pipe
controller in them.

The patch adds 4 setsockopt options at the Phonet stack level to enable
creation, enabling, disabling and destroying a pipe.
The patch also adds getsockopt options to query the state of pipe at any stage
ie. whether it is created or enabled.

The patch also implements negotiating the flow control and selects the best
flow control which is supported by modem and APE.

This patch has been tested on ST-Ericsson U8500 running Linux kernel and
works fine for GPRS data.

Kumar Sanghvi (2):
  Phonet: Implement Pipe Controller to support Nokia Slim Modems
  Documentation: Update Phonet doc for Pipe Controller implementation

 Documentation/networking/phonet.txt |   53 ++++
 include/linux/phonet.h              |    5 +
 include/net/phonet/pep.h            |   21 ++
 net/phonet/Kconfig                  |   11 +
 net/phonet/pep.c                    |  447 ++++++++++++++++++++++++++++++++++-
 5 files changed, 531 insertions(+), 6 deletions(-)

-- 
1.7.2.dirty


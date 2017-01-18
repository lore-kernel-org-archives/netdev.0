From: Ariel Almog <arielalmogworkemails@gmail.com>
Subject: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Wed, 18 Jan 2017 17:19:19 +0200
Message-ID: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: leon@kernel.org, linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35030 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdARPTV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 10:19:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry for resending.

General
*******

As of today, there is no single, simple, tool that allows monitoring
and configuration of RDMA stack.

For netdev stack there are few standard tools, such as ethtool and
iproute2. There is a need to add a matching tool which will allow
control and query of RDMA subsystem.

rdmatool will provide standard, provider agnostic, user interface.
RDMA user can use this interface to
* Query RDMA device capabilities
* Query RDMA device status and current open resources
* Fetching RDMA statistics
* Configure RDMA device

The rdmatool will have the ability to control RDMA stack which
includes the ib_device and RDMA protocol params.

It is a good point to highlight the similarity to ethtool. It manages
net_device, while rdmatool will manage RDMA stack.

As a proposal, it is appealing to have a similar design to ethtool for
rdmatool too. As ethtool, it should contain user space part, kernel
handler and vendor specific handler(s).

Another tool which allows similar functionality is iproute2. Iproute2
allows user space tools to configure and query transport, network and
link layer. The advantages of using iproute2 is the reuse of existing
tool and familiar interface in addition to the wide spreading of this tool.

As start point of the discussion, we would like to propose two
implementation options for the rdmatool:
(1) Build a tool using ABI interface. This will be a RDMA tool
    which will be distributed as part of RDMA package
(2) Enhancing iproute2 to include rdmatool functionality

Our opinion is that the new ABI interface provides vast functionality and
it will be a waste to use other interface for the same functionality.
Each of the proposed implementation above have their advantages, and we
would like to hear your opinion regarding this direction.

I=E2=80=99m posting this RFC in both netdev and linux-rdma communities in
order to get feedback on this topic.

General Description
*******************
The rdmatool will be combined from the following components:
* user space=E2=80=99s rdmatool - will be referred from now on as rdmatool-=
u.
* kernel=E2=80=99s rdmatool - will be referred from now on as rdmatool-k. T=
his part
  is in kernel, running under ibcore context
* ib_device=E2=80=99s rdma_ops - rdmatool-p is written by the provider.
  In case the provider doesn't provide rdma_ops code, a generic code will
  be used to provide the matching interface.

.------------------|
| rdmatool-u       |
|------------------|
 U    |
 ABI
 K    |
.------------------|
| rdmatool-k       |
|------------------|
  |
rdmatool_ops
  |
.---------------------------|
| generic rdma_ops          |
|---------------------------|--|
  | ib_device=E2=80=99s rdma_ops      |--|
  |--|------------------------|  |--|
     |--|------------------------|  |
    |---------------------------|

The protocol on top of the ABI interface handles the transaction of
information on both directions (rdmatool-u to rdmatool-k and vice versa).

The transaction protocol shall contain the following information:
* Command =E2=80=93 the requested operation by rdmatool-u
* ib_device =E2=80=93 the device to handle; a dedicated value will indicate=
 a stack
  layer transactions
* Ancillary information according to the command
Later on, after we will close direction and design concerns, we will start
defining the actual structure to be used.

Flexibility
***********
Some of the commands allow passing both standard and
vendor specific information.
In order to allow easy enhancement of the tool, an Matan's ABI [1]
mechanism can be used to pass the vendor specific information.

As examples:
(1) Statistics ops will return the standard counters. In addition, it can
    report on extra counters. The rdmatool-u will present the addition
    statistics as is.
(2) For configuration, where rdmatool-u finds undefined information at the
    end of the command line, it will pass it as is to the rdmatool-k which
    will pass it to the ops handler where it can be handled or ignored.

Persistence
***********
Another target that we would like to achieve is easy configuration.
rdmatool-u will provide an export mechanism mto store and restore configura=
tion
The configuration file will be human readable and will be parsed by the
various tools (systemd, udev, rdmatool-u, etc.).

Functionality
*************
The rdmatool will provide a platform which can grow as needed. The
initial functionality might include:
* help =E2=80=93 man page
* version =E2=80=93 version number
* statistics =E2=80=93 RDMA statistics =E2=80=93 such as port and QP statis=
tics
  To allow easy reading of statistics, we offer to use a filter functionali=
ty,
  allowing reading of statistics families, such as link layer, error
  counters, etc.
* protocol =E2=80=93 RoCE/iWARP/InfiniBand related configuration, such as R=
DMA
  congestion configuration and statistics
* query =E2=80=93 RDMA objects (qp, cq, srq, ..) information such as owner,
  status, type
* debug =E2=80=93 an interface to allow read and write from user space to t=
he
  provider RDMA driver, exposing debug information

We would like to get the community feedback regarding which solution shall =
be
used: a standalone tool in RDMA package (ABI) or adding functionality to
iproute2 as extension?

Reference
[1] [RFC ABI V6 00/14] SG-based RDMA ABI Proposal -
        https://www.spinics.net/lists/linux-rdma/msg43960.html

Thanks for feedback.
Ariel and Leon

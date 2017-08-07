From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH 0/6] In-kernel QMI handling
Date: Mon, 7 Aug 2017 10:38:42 -0700
Message-ID: <20170807173842.GI29306@minitux>
References: <20170804145938.25427-1-bjorn.andersson@linaro.org>
 <1501860967.939.6.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>,
        linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501860967.939.6.camel@redhat.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 04 Aug 08:36 PDT 2017, Dan Williams wrote:

> On Fri, 2017-08-04 at 07:59 -0700, Bjorn Andersson wrote:
> > This series starts by moving the common definitions of the QMUX
> > protocol to the
> > uapi header, as they are shared with clients - both in kernel and
> > userspace.
> > 
> > This series then introduces in-kernel helper functions for aiding the
> > handling
> > of QMI encoded messages in the kernel. QMI encoding is a wire-format
> > used in
> > exchanging messages between the majority of QRTR clients and
> > services.
> 
> This raises a few red-flags for me.

I'm glad it does. In discussions with the responsible team within
Qualcomm I've highlighted a number of concerns about enabling this
support in the kernel. Together we're continuously looking into what
should be pushed out to user space, and trying to not introduce
unnecessary new users.

> So far, we've kept almost everything QMI related in userspace and
> handled all QMI control-channel messages from libraries like libqmi or
> uqmi via the cdc-wdm driver and the "rmnet" interface via the qmi_wwan
> driver.  The kernel drivers just serve as the transport.
> 

The path that was taken to support the MSM-style devices was to
implement net/qrtr, which exposes a socket interface to abstract the
physical transports (QMUX or IPCROUTER in Qualcomm terminology).

As I share you view on letting the kernel handle the transportation only
the task of keeping track of registered services (service id -> node and
port mapping) was done in a user space process and so far we've only
ever have to deal with QMI encoded messages in various user space tools.

> Can you describe what kinds of in-kernel drivers need to actually parse
> QMI messages as part of their operation?
> 

= "sysmon"
sysmon is a mechanism in Qualcomm devices to notify remote processors
when other remote processors goes away. This is required for such things
as letting the modem firmware know that the audio path is gone in the
case that the adsp abruptly disappears - i.e. when the adsp hits a
watchdog bite and doesn't have a chance to close the modem<->audio
communication channels.

In previous platforms the sysmon messages was just handled by packed
structs, but this was changed to being done using QMI and IPCROUTER
recently.

These messages needs to be sent before we attempt to restart the remote
processor and doing this from user space causes synchronization issues.

= Qualcomm slimbus implementation
The slimbus implementation in Qualcomm MSM devices expects a few QMI
encoded control messages to be sent for configuration and power
management purposes. So in order to get audio from the audio blocks to
the codec we need to send a few QMI encoded messages in the Qualcomm
slimbus driver.

As this is used to communicate power management states from the kernel
driver I see it infeasible to do this from user space.

= IPQ8074 WiFi driver
In many Qualcomm SoC the WiFi solution is split between an in-SoC core
that does protocol handling and an off-chip RF module. The communication
of control messages with the protocol core is done over shared memory
transports (SMD or GLINK) and has in the past (WCN3620, 3660 and 3680)
been done with packed structs. In the latest incarnation this is
replaced by QMI-encoded messages.

Qualcomm is trying to move forward in upstreaming a driver for this, as
part of their push to get IPQ8074 support upstream. I have not reviewed
the new version of this driver, but the driver for the previous
generation dealt with a mixture of control messages, dealing with DMA
channels and direct hardware control - so this does indeed look to
require in-kernel QMI messaging.

Regards,
Bjorn

> Dan
> 
> > It then adds an abstractions to reduce the duplication of common code
> > in
> > drivers that needs to query the name server and send and receive
> > encoded
> > messages to a remote service.
> > 
> > Finally it introduces a sample implementation for showing QRTR and
> > the QMI
> > helpers in action. The sample device instantiates in response to
> > finding the
> > "test service" and implements the "test protocol".
> > 
> > Bjorn Andersson (6):
> >   net: qrtr: Invoke sk_error_report() after setting sk_err
> >   net: qrtr: Move constants to header file
> >   net: qrtr: Add control packet definition to uapi
> >   soc: qcom: Introduce QMI encoder/decoder
> >   soc: qcom: Introduce QMI helpers
> >   samples: Introduce Qualcomm QRTR sample client
> > 
> >  drivers/soc/qcom/Kconfig          |   8 +
> >  drivers/soc/qcom/Makefile         |   3 +
> >  drivers/soc/qcom/qmi_encdec.c     | 812
> > ++++++++++++++++++++++++++++++++++++++
> >  drivers/soc/qcom/qmi_interface.c  | 540 +++++++++++++++++++++++++
> >  include/linux/soc/qcom/qmi.h      | 249 ++++++++++++
> >  include/uapi/linux/qrtr.h         |  35 ++
> >  net/qrtr/qrtr.c                   |  16 +-
> >  samples/Kconfig                   |   8 +
> >  samples/Makefile                  |   2 +-
> >  samples/qrtr/Makefile             |   1 +
> >  samples/qrtr/qrtr_sample_client.c | 603 ++++++++++++++++++++++++++++
> >  11 files changed, 2261 insertions(+), 16 deletions(-)
> >  create mode 100644 drivers/soc/qcom/qmi_encdec.c
> >  create mode 100644 drivers/soc/qcom/qmi_interface.c
> >  create mode 100644 include/linux/soc/qcom/qmi.h
> >  create mode 100644 samples/qrtr/Makefile
> >  create mode 100644 samples/qrtr/qrtr_sample_client.c
> > 

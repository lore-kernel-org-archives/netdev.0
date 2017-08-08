From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH 0/6] In-kernel QMI handling
Date: Tue, 8 Aug 2017 15:42:35 -0700
Message-ID: <20170808224235.GK29306@minitux>
References: <20170804145938.25427-1-bjorn.andersson@linaro.org>
 <8737921fw2.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>,
        linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bj?rn Mork <bjorn@mork.no>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8737921fw2.fsf@miraculix.mork.no>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 08 Aug 04:02 PDT 2017, Bj?rn Mork wrote:

> Bjorn Andersson <bjorn.andersson@linaro.org> writes:
> 
> > This series starts by moving the common definitions of the QMUX protocol to the
> > uapi header, as they are shared with clients - both in kernel and userspace.
> >
> > This series then introduces in-kernel helper functions for aiding the handling
> > of QMI encoded messages in the kernel. QMI encoding is a wire-format used in
> > exchanging messages between the majority of QRTR clients and services.
> 
> Interesting!  I tried to add some QMI handling in the kernel a few years
> ago, but was thankfully voted down.  See
> https://www.spinics.net/lists/netdev/msg183101.html and the following
> discussion. I am convinced that was the right decision, for the client
> side at least. The protocol is just too extensive and ever-growing to be
> implemented in the kernel. We would be catching up forever.
> 
> Note that I had very limited knowledge of the protocol at the time I
> wrote that driver.  Still have, in fact :-)
> 

Thanks for the pointer, I definitely think there's more work to be done
here to figure out the proper way to interact with these devices.

But I think that Dan's reply shows a huge source of confusion here; the
acronym "QMI" covers a large amount of different things - and means
different things for different people.

In the modem world QMI seems to mean a defined set of logical endpoints
that accepts TLV-encoded messages to do modem-related things. But the
TLV-encoding is used for non-modem related services and the only common
denominator of everything called QMI is the TLV-encoding.


Due to my limited exposure to the USB attached "QMI thingies" I haven't
previously looked into the exact differences. The proposed patches aimed
to support implementing a few non-modem-related clients using
QMI-encoded messages over ipcrouter.

Looking at your patch above, and oPhono, seems to highlight a few
important differences that will take some thinking to overcome.

= Transport
The transport header in the USB case is your struct qmux, which contains
the type of message (in "flags") and the transaction id. The "service"
in the QMUX header matches the service id being communicated with. But
in order to communicate with a service it seems like one requests a
client-id from the control service.

In the smartphone world (with shared memory communication) the transport
is ipcrouter - with a header very similar to UDP - and there's no
information about the payload, it provides only the means of delivering
messages from one address/port to another address/port. A typical
smartphone has 3-4 nodes (modem, sensors, audio etc) and ports are
dynamically allocated. The control messages in the QMUX protocol (not
the same QMUX protocol as in the USB case!) are used for clients to find
the mapping from service id to a port on the given address.  The source
port is dynamically allocated in this case.

= QMI-encoded messages
The list of TLV-entries have a "QMI header" prepended in both cases, but
in the QMUX case the header consists only of "msgid" and length.

In the ipcrouter case the transport doesn't carry any information
regarding the payload, so the header prepended the TLV entries includes
"type", transaction id, "msg_id" and length.


It looks as if once past the differences in the transport and QMI
message header the messages (TLV-encoded data) are the same. But I'm not
yet sure about how we can hide the transport differences.

Regards,
Bjorn

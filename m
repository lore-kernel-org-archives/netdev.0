From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number next.
Date: Tue, 26 Apr 2005 10:57:55 -0500
Message-ID: <d120d5000504260857cb5f99e@mail.gmail.com>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
Reply-To: dtor_core@ameritech.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Greg KH <greg@kroah.com>,
        Jamal Hadi Salim <hadi@cyberus.ca>, Kay Sievers <kay.sievers@vrfy.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        James Morris <jmorris@redhat.com>,
        Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
        linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
        Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20050411125932.GA19538@uganda.factory.vocord.ru>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

On 4/11/05, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> /*****************************************/
> Kernel Connector.
> /*****************************************/
...
> +static int cn_call_callback(struct cn_msg *msg, void (*destruct_data) (void *), void *data)
> +{
> +       struct cn_callback_entry *__cbq;
> +       struct cn_dev *dev = &cdev;
> +       int found = 0;
> +
> +       spin_lock_bh(&dev->cbdev->queue_lock);
> +       list_for_each_entry(__cbq, &dev->cbdev->queue_list, callback_entry) {
> +               if (cn_cb_equal(&__cbq->cb->id, &msg->id)) {
> +                       __cbq->cb->priv = msg;
> +
> +                       __cbq->ddata = data;
> +                       __cbq->destruct_data = destruct_data;
> +
> +                       queue_work(dev->cbdev->cn_queue, &__cbq->work);

It looks like there is a problem with the code. As far as I can see
there is only one cn_callback_entry associated with each callback. So,
if someone sends netlink messages with the same id at a high enough
rate (so cbdev's work queue does not get a chance to get scheduled and
process pending requests) ddata and the destructor will be overwritten
which can lead to memory leaks and non-delivery of some messages.

Am I missing something?

-- 
Dmitry

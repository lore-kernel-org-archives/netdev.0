From: Denis Yefremov <yefremov.denis@gmail.com>
Subject: wlcore: might_sleep operation in interrupt handler
Date: Tue, 31 Jul 2012 22:28:14 +0400
Message-ID: <CADKZ3FKDw78ac9JPXJuw0s7Mqg1RrVfonbjXZ6zHmtwF2i5HoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Eliad Peller <eliad@wizery.com>,
	Arik Nemtsov <arik@wizery.com>, Eyal Shapira <eyal@wizery.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interrupt handler wlcore_irq in wlcore/main.c file
invokes mutex_lock that is might sleep operation.

Found by Linux Driver Verification project (linuxtesting.org)
within my participation in the GSoC 2012 program.

drivers/net/wireless/ti/wlcore/main.c

static irqreturn_t wlcore_irq(int irq, void *cookie)
{
        int ret;
        unsigned long flags;
        struct wl1271 *wl = cookie;

        /* TX might be handled here, avoid redundant work */
        set_bit(WL1271_FLAG_TX_PENDING, &wl->flags);
        cancel_work_sync(&wl->tx_work);

        mutex_lock(&wl->mutex);
...
}

int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
{
...
        ret = request_threaded_irq(wl->irq, wl12xx_hardirq, wlcore_irq,
                                   irqflags,
                                   pdev->name, wl);
...
}

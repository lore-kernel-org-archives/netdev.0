From: Jean Delvare <khali@linux-fr.org>
Subject: Shared i2c adapter locking (Was: linux-next: manual merge of the
 net tree with the i2c tree)
Date: Thu, 29 Oct 2009 15:43:17 +0100
Message-ID: <20091029154317.651904b9@hyperion.delvare>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Kuoppala <mika.kuoppala@nokia.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Linux I2C <linux-i2c@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754850AbZJ2OnT@vger.kernel.org>
In-Reply-To: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Mon, 26 Oct 2009 13:37:57 +1100, Stephen Rothwell wrote:
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/sfc/sfe4001.c between commit
> 3f7c0648f727a6d5baf6117653e4001dc877b90b ("i2c: Prevent priority
> inversion on top of bus lock") from the i2c tree and commit
> c9597d4f89565b6562bd3026adbe6eac6c317f47 ("sfc: Merge sfe4001.c into
> falcon_boards.c") from the net tree.
> 
> I have applied the following merge fixup patch (after removing
> drivers/net/sfc/sfe4001.c) and can carry it as necessary.

Thanks for fixing it. The core problem here IMHO is that the sfc
network driver touches i2c internals which it would rather leave alone.
This is the only driver I know of which does this.

I can think of 3 different ways to address the issue.

Method #1: add a public API to grab/release an I2C segment.

void i2c_adapter_lock(struct i2c_adapter *adapter)
{
	rt_mutex_lock(&adapter->bus_lock);
}

void i2c_adapter_unlock(struct i2c_adapter *adapter)
{
	rt_mutex_unlock(&adapter->bus_lock);
}

It has the advantage of simplicity. The problem is that it is not
symmetric. Whatever shares the pins with I2C, I2C is considered the
main user in that its mutex is used to guarantee mutual exclusion. If
the other subsystem also has a mandatory locking mechanism, there will
have to be a decision on who is locked first. If not all drivers agree,
lockdep will get confused.

Method #2: let the driver implement its own "main" locking, and have
all pin users (i2c etc.) take it in addition to any subsystem-specific
mutex. As far as the sfc network driver is concerned, that would mean
adding pre-xfer and post-xfer hooks to i2c-algo-bit, where the "main"
mutex in question would be taken resp. released.

It has the advantage of symmetry. The problem is performance, as
regular operation will require to take and release two mutexes instead
of just one. But it is a fairly generic approach which could solve
other issues too.

Method #3: let individual bus drivers implement segment locking
themselves, with custom locking/unlocking hooks. This way, a device
sharing pins between several functions can have its own mutex
protecting these pins globally, and all user subsystems (i2c etc.) use
this single mutex.

It has the advantage of performance and symmetry, at the price of
fragility. If the i2c bus driver implements locking improperly... I am
also worried by inconsistencies that may arise, if different i2c
adapters are protected by different mutex types (mutex vs. real-time
mutex vs. spinlock etc.) but maybe this will be seen as an advantage
rather than a problem.

I'm not really sure if I have a preference yet, so please speak up if
you do.

-- 
Jean Delvare
